// Copyright 2020 The Beam Team
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

#include "exchange_rates_manager.h"

// test
#include "utility/logger.h"

ExchangeRatesManager::ExchangeRatesManager()
    : m_walletModel(*AppModel::getInstance().getWallet())
{
    qRegisterMetaType<std::vector<beam::wallet::ExchangeRate>>("std::vector<beam::wallet::ExchangeRate>");

    connect(&m_walletModel,
            SIGNAL(exchangeRatesUpdate(const std::vector<beam::wallet::ExchangeRate>&)),
            SLOT(onExchangeRatesUpdate(const std::vector<beam::wallet::ExchangeRate>&)));
}

void ExchangeRatesManager::onExchangeRatesUpdate(const std::vector<beam::wallet::ExchangeRate>& rates)
{
    // TEST
    for (const auto& rate : rates)
    {
        LOG_DEBUG() << "Exchange rate: 1 " << beam::wallet::ExchangeRate::to_string(rate.m_currency) << " = "
                    << rate.m_rate << " " << beam::wallet::ExchangeRate::to_string(rate.m_unit);
    }
}