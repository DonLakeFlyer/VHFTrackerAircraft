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
    property color  _pulseColorLeft:        _strongPulseColor
    property color  _pulseColorRight:       _strongPulseColor
    property bool   _trackingLeftTurn:      false
    property bool   _trackingRightTurn:     false
    property int    _trackStrongestPulse:   0
    property real   _trackStrongestHeading: 0
    property real   _vehicleHeading:        QGroundControl.qgcPositionManager.heading

    readonly property color _strongPulseColor:  "green"
    readonly property color _weakPulseColor:    "red"

    BluetoothSocket {
        id:         btSocket
        service:    BluetoothService {
            id:                 btService
            serviceProtocol:    BluetoothService.RfcommProtocol
            serviceUuid:        "94f39d29-7d6d-437d-973b-fba39e49d4ee"
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

    /*
    BluetoothDiscoveryModel {
        remoteAddress: "B8:27:EB:F3:4F:9D"
        discoveryMode: BluetoothDiscoveryModel.FullServiceDiscovery

        onErrorChanged: console.log("Discover error", error)
        onDeviceDiscovered: console.log("device discovered", device)
        onServiceDiscovered: console.log("service discovered", service.serviceUuid)
    }*/

    function _updateSignalColors() {
        if (_pulseStrengthLeft > _pulseStrengthRight) {
            _pulseColorLeft = _strongPulseColor
            _pulseColorRight = _weakPulseColor
        } else {
            _pulseColorLeft = _weakPulseColor
            _pulseColorRight = _strongPulseColor
        }
    }

    function _startTracking() {
        _trackStrongestHeading = 0
        _trackStrongestPulse = -1
        if (_trackingLeftTurn) {
            _updateTurnTracking(_pulseStrengthLeft)
        }
        if (_trackingRightTurn) {
            _updateTurnTracking(_pulseStrengthRight)
        }
    }

    function _updateTurnTracking(pulseStrength) {
        if (pulseStrength > _trackStrongestPulse) {
            var newHeading = _vehicleHeading
            if (_trackingLeftTurn) {
                newHeading += 90.0
            } else {
                newHeading -= 90.0
            }
            console.log("newheading", newHeading)
            _trackStrongestHeading = normalizeHeading(newHeading)
            console.log("newheading", newHeading)
            _trackStrongestPulse = pulseStrength
        }
        trackStrongHeadingLabel.text = "Heading: " + _trackStrongestHeading.toFixed(0) + "  Pulse: " + _trackStrongestPulse
    }

    function setGain(gain) {
        if (btSocket.connected) {
            btSocket.stringData = "gain " + gain + "\n"
        }
    }

    function setFrequency(freq) {
        if (btSocket.connected) {
            btSocket.stringData = "freq " + freq + "\n"
        }
    }

    function setAmp(amp) {
        if (btSocket.connected) {
            btSocket.stringData = "amp " + amp + "\n"
        }
    }

    function normalizeHeading(heading) {
        if (heading < 0) {
            heading += 360.0
        } else if (heading >= 360) {
            heading -= 360.0
        }
        return heading
    }

    on_PulseStrengthLeftChanged: {
        _updateSignalColors()
        if (_trackingLeftTurn) {
            _updateTurnTracking(_pulseStrengthLeft)
        }
    }

    on_PulseStrengthRightChanged: {
        _updateSignalColors()
        if (_trackingRightTurn) {
            _updateTurnTracking(_pulseStrengthRight)
        }
    }

/*
    SequentialAnimation on _pulseStrengthLeft {
        loops: Animation.Infinite

        NumberAnimation {
            from: 0
            to: 600
            duration: 20000
        }
    }

    SequentialAnimation on _pulseStrengthRight {
        loops: Animation.Infinite

        NumberAnimation {
            from: 600
            to: 0
            duration: 20000
        }
    }
*/

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
                border.color:               pulseColor

                Rectangle {
                    anchors.margins:        1
                    anchors.bottomMargin:   _bottomMargin
                    anchors.fill:           parent
                    color:                  pulseColor

                    property real   _maximumPulse:   600
                    property real   _value:         pulseStrength
                    property real   _bottomMargin:  (parent.height - 2) - ((parent.height - 2) * (Math.min(pulseStrength, _maximumPulse) / _maximumPulse))
                }
            }
        }
    }

    Loader {
        id:                 leftPulseIndicator
        anchors.margins:    _margins
        anchors.left:       parent.left
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        sourceComponent:    signalStrengthControl

        property int pulseStrength: _pulseStrengthLeft
        property int pulseCount:    _pulseCountLeft
        property color pulseColor:  _pulseColorLeft
    }

    Loader {
        id:                 rightPulseIndicator
        anchors.margins:    _margins
        anchors.right:      parent.right
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        sourceComponent:    signalStrengthControl

        property int pulseStrength: _pulseStrengthRight
        property int pulseCount:    _pulseCountRight
        property color pulseColor:  _pulseColorRight
    }

    QGCLabel {
        id:                         trackStrongHeadingLabel
        anchors.horizontalCenter:   parent.horizontalCenter
        font.pointSize:             ScreenTools.largeFontPointSize * 2
        color:                      "white"
    }

    QGCButton {
        anchors.leftMargin: _margins
        anchors.left:       leftPulseIndicator.right
        anchors.bottom:     leftPulseIndicator.bottom
        pointSize:          ScreenTools.largeFontPointSize
        text:               _trackingLeftTurn ? "Stop Tracking" : "Track Left Turn"
        enabled:            !_trackingRightTurn

        onClicked: {
            _trackingLeftTurn = !_trackingLeftTurn
            _startTracking()
        }
    }

    QGCButton {
        id:                     rightTurnButton
        anchors.rightMargin:    _margins
        anchors.right:          rightPulseIndicator.left
        anchors.bottom:         rightPulseIndicator.bottom
        pointSize:              ScreenTools.largeFontPointSize
        text:                   _trackingRightTurn ? "Stop Tracking" : "Track Right Turn"
        enabled:                !_trackingLeftTurn

        onClicked: {
            _trackingRightTurn = !_trackingRightTurn
            _startTracking()
        }
    }

    /*
    QGCButton {
        anchors.leftMargin: _margins
        anchors.left:       leftPulseIndicator.right
        anchors.top:        leftPulseIndicator.bottom
        pointSize:          ScreenTools.largeFontPointSize
        text:               _nullTracking ? "Stop Tracking" : "Null Tracking"
        enabled:            !_trackingRightTurn

        onClicked: {
            _trackingLeftTurn = !_trackingLeftTurn
            _startTracking()
        }
    }*/

    ColumnLayout {
        anchors.rightMargin:    _margins
        anchors.bottomMargin:   ScreenTools.defaultFontPixelHeight * 2
        anchors.right:          rightPulseIndicator.left
        anchors.top:            rightPulseIndicator.top
        anchors.bottom:         rightTurnButton.top
        spacing:                _margins

        QGCLabel {
            color:              "white"
            text:               "Gain"
            Layout.alignment:   Qt.AlignHCenter
        }

        QGCLabel {
            color:              "white"
            text:               gainSlider.value
            font.pointSize:     ScreenTools.largeFontPointSize
            Layout.alignment:   Qt.AlignHCenter
        }

        Slider {
            id:                         gainSlider
            anchors.bottom:             parent.bottom
            minimumValue:               1
            maximumValue:               50
            value:                      1
            orientation:                Qt.Vertical
            updateValueWhileDragging:   false
            stepSize:                   1
            Layout.fillHeight:          true
            Layout.alignment:           Qt.AlignHCenter

            onValueChanged: setGain(value)
        }
    }

    QGCTextField {
        id:                 freqField
        anchors.leftMargin: _margins
        anchors.left:       leftPulseIndicator.right
        anchors.top:        leftPulseIndicator.top
        font.pointSize:     ScreenTools.largeFontPointSize
        text:               "146000000"

        onEditingFinished: setFrequency(parseInt(text))
    }

    QGCCheckBox {
        anchors.topMargin:  _margins
        anchors.left:       freqField.left
        anchors.top:        freqField.bottom
        text:               "Amplifier"
        onClicked:          setAmp(checked ? 1 : 0)
    }
}
