/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick              2.3
import QtQuick.Layouts      1.2
import QtQuick.Controls     1.2
import QtPositioning        5.2
import QtBluetooth          5.2

import QGroundControl                   1.0
import QGroundControl.Controls          1.0
import QGroundControl.FactControls      1.0
import QGroundControl.Palette           1.0
import QGroundControl.ScreenTools       1.0
import QGroundControl.Controllers       1.0
import QGroundControl.SettingsManager   1.0

Item {
    id:             flyOVerlay
    anchors.fill:   parent

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    readonly property string scaleState: "topMode"

    property var    _corePlugin:            QGroundControl.corePlugin
    property real   _margins:               ScreenTools.defaultFontPixelWidth
    property int    _pulseCountLeft:        0
    property int    _pulseCountRight:       0
    property int    _pulseStrengthLeft:     0
    property int    _pulseStrengthRight:    0

    BluetoothSocket {
        id:         btSocket
        service:    BluetoothService {
            id:                 btService
            serviceProtocol:    BluetoothService.RfcommProtocol
            deviceAddress:      "B8:27:EB:F3:4F:9D"
        }

        connected:  true
        
        onErrorChanged: console.log("Socket error", error)

        onStringDataChanged: {
            var pulseStrengthStr
            var pulseStr = stringData
            if (pulseStr.startsWith("left ")) {
                pulseStrengthStr = pulseStr.substring(5, 100)
                _pulseCountLeft++
                _pulseStrengthLeft = parseFloat(pulseStrengthStr)
            } else if (pulseStr.startsWith("right ")) {
                pulseStrengthStr = pulseStr.substring(6, 100)
                _pulseCountRight++
                _pulseStrengthRight = parseFloat(pulseStrengthStr)
            }
        }
    }

    Component {
        id: signalStrengthControl

        Rectangle {
            width:  ScreenTools.defaultFontPixelHeight * 4
            color:  "white"

            Column {
                id:                 valueColumn
                anchors.margins:    _margins
                anchors.left:       parent.left
                anchors.right:      parent.right

                QGCLabel {
                    anchors.horizontalCenter:   parent.horizontalCenter
                    text:                       pulseStrength
                    color:                      "black"
                    font.pointSize:             ScreenTools.largeFontPointSize
                }

                QGCLabel {
                    anchors.horizontalCenter:   parent.horizontalCenter
                    text:                       pulseCount
                    color:                      "black"
                }
            }

            Rectangle {
                anchors.margins:            _margins
                anchors.horizontalCenter:   parent.horizontalCenter
                anchors.top:                valueColumn.bottom
                anchors.bottom:             parent.bottom
                width:                      ScreenTools.defaultFontPixelHeight * 2
                border.color:               "green"

                Rectangle {
                    anchors.margins:        1
                    anchors.bottomMargin:   _bottomMargin
                    anchors.fill:           parent
                    color:                  "green"

                    property real   _maximumPulse:   600
                    property real   _value:         pulseStrength
                    property real   _bottomMargin:  (parent.height - 2) - ((parent.height - 2) * (Math.min(pulseStrength, _maximumPulse) / _maximumPulse))
                }
            }
        }
    }

    Loader {
        anchors.margins:    _margins
        anchors.left:       parent.left
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        sourceComponent:    signalStrengthControl

        property int pulseStrength: _pulseStrengthLeft
        property int pulseCount:    _pulseCountLeft
    }

    Loader {
        anchors.margins:    _margins
        anchors.right:      parent.right
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        sourceComponent:    signalStrengthControl

        property int pulseStrength: _pulseStrengthRight
        property int pulseCount:    _pulseCountRight
    }
}
