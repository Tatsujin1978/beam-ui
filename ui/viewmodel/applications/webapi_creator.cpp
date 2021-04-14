// Copyright 2018 The Beam Team
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
#include <QQmlEngine>
#include "webapi_creator.h"
#include "wallet/api/i_wallet_api.h"

namespace beamui::applications
{
    WebAPICreator::WebAPICreator(QObject *parent)
        : QObject(parent)
    {
        _amgr = AppModel::getInstance().getAssets();
    }

    WebAPICreator::~WebAPICreator()
    {
    }

    void WebAPICreator::createApi(const QString &version, const QString &appName, const QString &appUrl)
    {
        using namespace beam::wallet;

        const auto stdver = version.toStdString();
        if (!IWalletApi::ValidateAPIVersion(stdver))
        {
            //% "Unsupported API version requested: %1"
            const auto error = qtTrId("apps-bad-api-version").arg(version);
            return qmlEngine(this)->throwError(error);
        }

        ECC::Hash::Value hv;
        ECC::Hash::Processor() << appName.toStdString() << appUrl.toStdString() >> hv;
        const auto appid = std::string("appid:") + hv.str();

        _webShaders = std::make_shared<WebAPI_Shaders>(*this, appid);
        _api = std::make_unique<WebAPI_Beam>(*this, _webShaders, stdver, appid);

        QQmlEngine::setObjectOwnership(_api.get(), QQmlEngine::CppOwnership);
        emit apiCreated(_api.get());
    }

    void WebAPICreator::AnyThread_getSendConsent(const std::string& request, const beam::wallet::IWalletApi::ParseResult& pinfo)
    {
        using namespace beam::wallet;

        //
        // Do not assume thread here
        // Should be safe to call from any thread
        //
        const auto& spend = pinfo.minfo.spend;
        const auto fee = pinfo.minfo.fee;

        if (spend.size() != 1)
        {
            assert(!"tx_send must spend strictly 1 asset");
            return _api->AnyThread_sendRejected(request, ApiError::NotAllowedError, "tx_send must spend strictly 1 asset");
        }

        const auto assetId = spend.begin()->first;
        const auto amount = spend.begin()->second;

        QMap<QString, QVariant> info;
        info.insert("amount",     AmountBigToUIString(amount));
        info.insert("fee",        AmountToUIString(fee));
        info.insert("feeRate",    AmountToUIString(_amgr->getRate(beam::Asset::s_BeamID)));
        info.insert("unitName",   _amgr->getUnitName(assetId, AssetsManager::NoShorten));
        info.insert("rate",       AmountToUIString(_amgr->getRate(assetId)));
        info.insert("rateUnit",   _amgr->getRateUnit());
        info.insert("token",      QString::fromStdString(pinfo.minfo.token));
        info.insert("tokenType",  GetTokenTypeUIString(pinfo.minfo.token, pinfo.minfo.spendOffline));
        info.insert("isOnline",   !pinfo.minfo.spendOffline);
        info.insert("comment",    QString::fromStdString(pinfo.minfo.comment));

        if (const auto params = ParseParameters(pinfo.minfo.token))
        {
            if (const auto walletID = params->GetParameter<beam::wallet::WalletID>(TxParameterID::PeerID))
            {
                const auto widStr = std::to_string(*walletID);
                info.insert("walletID", QString::fromStdString(widStr));
            }
            else
            {
                assert(!"Wallet ID is missing");
            }
        }
        else
        {
            assert(!"Failed to parse token");
        }

        emit approveSend(QString::fromStdString(request), info);
    }

    void WebAPICreator::AnyThread_getContractConsent(const beam::ByteBuffer& buffer)
    {
        //
        // Do not assume thread here
        // Should be safe to call from any thread
        //
        _webShaders->AnyThread_contractAllowed();
    }

    void WebAPICreator::sendApproved(const QString& request)
    {
        //
        // This is UI thread
        //
        _api->AnyThread_sendApproved(request.toStdString());
    }

    void WebAPICreator::sendRejected(const QString& request)
    {
        //
        // This is UI thread
        //
        _api->AnyThread_sendRejected(request.toStdString(), beam::wallet::ApiError::UserRejected, std::string());
    }
}