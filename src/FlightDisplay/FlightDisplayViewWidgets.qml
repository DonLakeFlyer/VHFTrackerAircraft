/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs          1.2
import QtLocation               5.3
import QtPositioning            5.3
import QtQuick.Layouts          1.2

import QGroundControl                           1.0
import QGroundControl.ScreenTools               1.0
import QGroundControl.Controls                  1.0
import QGroundControl.Palette                   1.0
import QGroundControl.Vehicle                   1.0
import QGroundControl.FlightMap                 1.0

Item {
    id: _root

    property var    qgcView
    property bool   useLightColors
    property var    missionController

    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property bool   _isSatellite:           _mainIsMap ? (_flightMap ? _flightMap.isSatelliteMap : true) : true
    property bool   _lightWidgetBorders:    _isSatellite

    readonly property real _margins:        ScreenTools.defaultFontPixelHeight * 0.5

    QGCMapPalette { id: mapPal; lightColors: useLightColors }
    QGCPalette    { id: qgcPal }

    function getPreferredInstrumentWidth() {
        if(ScreenTools.isMobile) {
            return ScreenTools.isTinyScreen ? mainWindow.width * 0.2 : mainWindow.width * 0.15
        }
        return ScreenTools.defaultFontPixelWidth * 30
    }

    Connections {
        target:         QGroundControl.settingsManager.appSettings.virtualJoystick
        onValueChanged: _setInstrumentWidget()
    }

    Connections {
        target:         QGroundControl.settingsManager.appSettings.showLargeCompass
        onValueChanged: _setInstrumentWidget()
    }

    //-- Map warnings
    Column {
        anchors.horizontalCenter:   parent.horizontalCenter
        anchors.top:                parent.verticalCenter
        spacing:                    ScreenTools.defaultFontPixelHeight

        QGCLabel {
            anchors.horizontalCenter:   parent.horizontalCenter
            visible:                    _activeVehicle && !_activeVehicle.coordinate.isValid && _mainIsMap
            z:                          QGroundControl.zOrderTopMost
            color:                      mapPal.text
            font.pointSize:             ScreenTools.largeFontPointSize
            text:                       qsTr("No GPS Lock for Vehicle")
        }

        QGCLabel {
            anchors.horizontalCenter:   parent.horizontalCenter
            visible:                    _activeVehicle && _activeVehicle.prearmError
            z:                          QGroundControl.zOrderTopMost
            color:                      mapPal.text
            font.pointSize:             ScreenTools.largeFontPointSize
            text:                       _activeVehicle ? _activeVehicle.prearmError : ""
        }

        QGCLabel {
            anchors.horizontalCenter:   parent.horizontalCenter
            visible:                    _activeVehicle && _activeVehicle.prearmError
            width:                      ScreenTools.defaultFontPixelWidth * 50
            horizontalAlignment:        Text.AlignHCenter
            wrapMode:                   Text.WordWrap
            z:                          QGroundControl.zOrderTopMost
            color:                      mapPal.text
            font.pointSize:             ScreenTools.largeFontPointSize
            text:                       "The vehicle has failed a pre-arm check. In order to arm the vehicle, resolve the failure or disable the arming check via the Safety tab on the Vehicle Setup page."
        }
    }

    //-- Instrument Panel
    Loader {
        id:                     instrumentsLoader
        anchors.margins:        ScreenTools.defaultFontPixelHeight / 2
        anchors.right:          parent.right
        anchors.top:            _root.top
        z:                      QGroundControl.zOrderWidgets
        source:                 "qrc:/qml/QGCInstrumentWidgetAlternate.qml"

        property var  qgcView:      _root.qgcView
        property real maxHeight:    parent.height - (anchors.margins * 2)
    }
}
