import QtQuick          2.15
import QtQuick.Layouts  1.12
import QtQuick.Controls 2.4
import Beam.Wallet      1.0
import "../controls"

CustomDialog {
    id:      control
    width:   764
    height:  544
    x:       Math.round((parent.width - width) / 2)
    y:       Math.round((parent.height - height) / 2)
    parent:  Overlay.overlay
    modal:   true
    padding: 0

    property string dappName:          ""
    readonly property bool isUpdating: !!dappName
    property var appFileProperties:    undefined
    property bool isOk:                true

    // TODO: provide real data
    property var app: {"name": "Test", "description": "description", "supported": true, "release_date": "12-02-2022", "version": "1.1.1.1", "api_version": "6.3", "min_api_version": "6.1", "guid": "2e77e992e2844b58b84034bbb51770f9"}

    onClosed: {
        // reset
        isOk = true
        stackView.replace(startViewId)
        appFileProperties = undefined
        dappName = ""
    }

    function loadDappFile(filename) {
        if (!filename)
        {
            // TODO: chooseFile
        }
        appFileProperties = {"name": "testapp.dapp", "size": "10 Mb"}
    }

    contentItem: StackView {
        id: stackView
        Layout.fillWidth: true
        Layout.fillHeight: true
        initialItem: startViewId
        replaceEnter: Transition {
            enabled: false
        }
        replaceExit: Transition {
            enabled: false
        }
        onCurrentItemChanged: {
            if (currentItem && currentItem.defaultFocusItem) {
                stackView.currentItem.defaultFocusItem.forceActiveFocus();
            }
        }
    }
    
    Component {
        id: startViewId

        Item {
            ColumnLayout {
                spacing:              30
                anchors.fill:         parent
                anchors.topMargin:    40
                anchors.bottomMargin: 40
                anchors.leftMargin:   100
                anchors.rightMargin:  100

                // Title
                SFText {
                    Layout.fillWidth:     true
                    color:                Style.content_main
                    horizontalAlignment:  Text.AlignHCenter
                    font.pixelSize:       18
                    font.weight:          Font.Normal
                    text:                 control.isUpdating ?
                                          //% "Update DApp"
                                          qsTrId("dapps-store-update-dapp-title") :
                                          //% "Upload new DApp"
                                          qsTrId("dapps-store-upload-new-dapp-title")

                }

                // Note
                SFText {
                    Layout.fillWidth:     true
                    visible:              !errorMsg.visible
                    color:                Style.content_main
                    horizontalAlignment:  Text.AlignHCenter
                    font.pixelSize:       14
                    font.weight:          Font.Normal
                    text:                 control.isUpdating ?
                                          //% "To update %1, please add the new version of the file below"
                                          qsTrId("dapps-store-update-dapp-text").arg(dappName):
                                          //% "To upload your own DApp in the DApp Store, please use files in the .dapp format only"
                                          qsTrId("dapps-store-upload-new-dapp-text")
                }

                // Error
                SFText {
                    id:                   errorMsg
                    visible:              !control.isOk
                    Layout.fillWidth:     true
                    color:                Style.validator_error
                    horizontalAlignment:  Text.AlignHCenter
                    font.pixelSize:       14
                    font.weight:          Font.Normal
                                          //% "Something went wrong, please check your file and to try upload it again"
                    text:                 qsTrId("dapps-store-upload-common-error")
                }

                // Body
                Rectangle {
                    Layout.fillWidth:   true
                    Layout.fillHeight:  true
                    radius:             10
                    color:              Qt.rgba(26, 246, 214, 0.1)

                    Canvas {
                        anchors.fill: parent
                        antialiasing: true
                        visible:      !control.appFileProperties

                        onPaint: function (rect) {
                            var radius = 10
                            var ctx = getContext("2d")
                            ctx.save()
                            ctx.setLineDash([5, 5])
                            ctx.roundedRect(0, 0, rect.width, rect.height, radius, radius)
                            ctx.strokeStyle = "#1AF6D6"
                            ctx.stroke()
                            ctx.restore()
                        }
                    }

                    // show DApp file properties
                    ColumnLayout { 
                        spacing:           0
                        anchors.fill:      parent
                        visible:           !!control.appFileProperties

                        Item {
                            Layout.fillHeight: true
                        }

                        SvgImage {
                            source:           "qrc:/assets/icon-dapps_store-dapp-file.svg"
                            Layout.alignment: Qt.AlignHCenter
                            sourceSize:       Qt.size(66, 85)
                        }

                        SFText {
                            Layout.topMargin:     20
                            Layout.fillWidth:     true
                            color:                Style.content_main
                            horizontalAlignment:  Text.AlignHCenter
                            font.pixelSize:       14
                            font.italic:          true
                            text:                 parent.visible ? appFileProperties.name : ""
                        }

                        SFText {
                            Layout.fillWidth:     true
                            color:                Style.content_secondary
                            horizontalAlignment:  Text.AlignHCenter
                            font.pixelSize:       14
                            font.italic:          true
                            text:                 parent.visible ? appFileProperties.size : ""
                        }

                        Item {
                            Layout.fillHeight: true
                        }
                    }

                    // start screen with "load .dapp file" button
                    ColumnLayout {
                        anchors.fill: parent
                        spacing:      20
                        visible:      !control.appFileProperties

                        CustomButton {
                            Layout.topMargin:    96
                            Layout.alignment:    Qt.AlignHCenter
                            palette.button:      Style.active
                            icon.source:         "qrc:/assets/icon-add.svg"
                            icon.height:         10
                            icon.width:          12
                                                 //% "load .dapp file"
                            text:                qsTrId("dapp-store-load-file")
                            palette.buttonText:  Style.content_opposite
                            onClicked:           control.loadDappFile()
                        }

                        SFText {
                            Layout.fillWidth:     true
                            Layout.fillHeight:    true
                            color:                Style.content_main
                            horizontalAlignment:  Text.AlignHCenter
                            font.pixelSize:       14
                            font.weight:          Font.Normal
                                                  //% "or jusr drop it here"
                            text:                 qsTrId("dapps-store-drop-text")
                        }
                    }

                    MouseArea {
                        enabled:         !control.appFileProperties
                        anchors.fill:    parent
                        acceptedButtons: Qt.LeftButton
                        hoverEnabled:    true
                        cursorShape:     enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked:       control.loadDappFile()
                    }

                    DropArea {
                        anchors.fill: parent
                        enabled:      !control.appFileProperties

                        onEntered: function (drag) {
                            if (drag.urls && drag.urls.length == 1) {
                                let filename = drag.urls[0]
                                if (filename.startsWith("file:///") && filename.endsWith(".dapp")) {
                                    drag.accepted = true
                                    return
                                }
                            }
                            drag.accepted = false
                        }

                        onDropped: function (drag) {
                            let filename = drag.urls[0]
                            control.loadDappFile(filename);
                        }
                    }
                }

                // Buttons 
                RowLayout {
                    Layout.fillWidth: true
                    spacing:          20

                    Item {
                        Layout.fillWidth: true
                    }

                    CustomButton {
                        icon.source: "qrc:/assets/icon-cancel-white.svg"
                        text:        qsTrId("general-cancel")
                        onClicked:   control.close()
                    }

                    CustomButton {
                        enabled:             !!control.appFileProperties
                        palette.button:      Style.active
                        icon.source:         "qrc:/assets/icon-dapps_store-add-publisher-submit.svg"
                        icon.height:         10
                        icon.width:          12
                                             //% "continue"
                        text:                qsTrId("general-continue")
                        palette.buttonText:  Style.content_opposite
                        onClicked:           stackView.replace(detailsId)
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }

    Component {
        id: detailsId

        Item {
            ColumnLayout {
                spacing:              30
                anchors.fill:         parent
                anchors.topMargin:    40
                anchors.bottomMargin: 40
                anchors.leftMargin:   100
                anchors.rightMargin:  100

                // Title
                SFText {
                    Layout.fillWidth:    true
                    color:               Style.content_main
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize:      18
                    font.weight:         Font.Normal
                    text:                control.isUpdating ?
                                         //% "Update DApp"
                                         qsTrId("dapps-store-update-dapp-title") :
                                         //% "Upload new DApp"
                                         qsTrId("dapps-store-upload-new-dapp-title")

                }

                // Note
                SFText {
                    Layout.fillWidth:    true
                    color:               Style.content_main
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize:      14
                    font.weight:         Font.Normal
                    text:                
/*% "Check the information below and select \"publish\".
If something is wrong, please cancel the uploading,
change the information in your file and upload your file again." */
                                          qsTrId("dapps-store-upload-check-details-text")
                }

                // Body
                AppPanel {
                    Layout.alignment: Qt.AlignHCenter
                    showButtons:      false    
                    app:              control.app
                }

                // DApp's properties
                ColumnLayout {
                    Layout.topMargin:  -10
                    Layout.alignment:  Qt.AlignHCenter
                    Layout.fillHeight: true

                    Repeater {
                                 //% "Release date:"
                        model: [[qsTrId("dapps-store-dapp-release-date"), control.app.release_date],
                                //% "Version:"
                                [qsTrId("dapps-store-dapp-version"), control.app.version],
                                //% "Api version:"
                                [qsTrId("dapps-store-dapp-api-version"), control.app.api_version],
                                //% "Minimal api version:"
                                [qsTrId("dapps-store-dapp-min-api-version"), control.app.min_api_version],
                                //% "Guid:"
                                [qsTrId("dapps-store-dapp-guid"), control.app.guid]
                               ]
                        RowLayout {
                            spacing: 5
                            SFText {
                                text:           modelData[0]
                                font.pixelSize: 12
                                elide:          Text.ElideRight
                                color:          Style.content_secondary
                            }
                            SFText {
                                text:           modelData[1]
                                font.pixelSize: 12
                                elide:          Text.ElideRight
                                color:          Style.content_main
                            }
                        }
                    }
                }

                // Buttons 
                RowLayout {
                    Layout.fillWidth: true
                    spacing:          20

                    Item {
                        Layout.fillWidth: true
                    }

                    CustomButton {
                        icon.source: "qrc:/assets/icon-cancel-white.svg"
                        text:        qsTrId("general-cancel")
                        onClicked:   control.close()
                    }

                    CustomButton {
                        palette.button:     Style.active
                        icon.source:        "qrc:/assets/icon-dapps_store-add-publisher-submit.svg"
                        icon.height:        10
                        icon.width:         12
                                            //% "publish"
                        text:               qsTrId("dapps-store-publish")
                        palette.buttonText: Style.content_opposite
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}