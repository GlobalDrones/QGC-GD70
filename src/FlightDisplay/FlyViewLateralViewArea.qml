import QtQuick 2.12
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.12

import QtLocation 5.3
import QtPositioning 5.3
import QtQuick.Window 2.2
import QtQml.Models 2.1

import QGroundControl 1.0
import QGroundControl.Airspace 1.0
import QGroundControl.Airmap 1.0
import QGroundControl.Controllers 1.0
import QGroundControl.Controls 1.0
import QGroundControl.FactControls 1.0
import QGroundControl.FactSystem 1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0
import QGroundControl.Vehicle 1.0

import QtGraphicalEffects 1.0

import SiYi.Object 1.0
import "qrc:/qml/QGroundControl/Controls"
import "qrc:/qml/QGroundControl/FlightDisplay"

/*
Depois de anos com flyview monolítico, finalmente separei algumas coisas em componentes menores. Se isso ajudar quem for mexer no código futuramente,
amém. - Russi 19/02/26
*/
Item {
    id: root

    property var activeVehicle

    property int _gasolineBatteryId: 2      // Sensor de nivel de combustivel = Batt[2]
    property real _maxConsumed: 5000        // Capacidade do tanque (5000 = 5L), igual ao BatteryIndicator
    property real _secondsPerLiter: 600     // 1L a cada 10min

    property real gasolinaLiters: NaN
    property string estimatedTimeText: "--:--:--"

    property real sectionHeight: height / 6


    //=====================================================================
    // GASOLINA (L) - media movel do sensor de nivel, sem leituras 255
    //=====================================================================

    Binding {
        target: root
        property: "gasolinaLiters"
        value: {
            if (!activeVehicle) return NaN

            for (var i = 0; i < activeVehicle.batteries.count; i++) {
                var battery = activeVehicle.batteries.get(i)
                if (battery.id.rawValue === _gasolineBatteryId) {
                    return Math.max(0, (_maxConsumed - battery.mahConsumedAvg.rawValue) / 1000)
                }
            }
            return NaN
        }
    }


    //=====================================================================
    // TEMPO ESTIMADO
    //=====================================================================

    Binding {
        target: root
        property: "estimatedTimeText"
        value: {
            if (!activeVehicle) return "--:--:--"

            var totalSeconds = gasolinaLiters * _secondsPerLiter

            if (!totalSeconds || isNaN(totalSeconds))
                return "--:--:--"

            var h = Math.floor(totalSeconds / 3600)
            var m = Math.floor((totalSeconds % 3600) / 60)
            var s = Math.floor(totalSeconds % 60)

            function pad(v) { return v < 10 ? "0" + v : v }

            return pad(h) + ":" + pad(m) + ":" + pad(s)
        }
    }


    function safe(v, digits) {
        if (!v || isNaN(v))
            return "0"
        return Number(v).toFixed(digits)
    }


    Rectangle {
        anchors.fill: parent
        color: qgcPal.toolbarBackground
    }


    Column {
        anchors.fill: parent
        spacing: 0


        //==============================================================
        // EST TIME
        //==============================================================

        Item {
            width: parent.width
            height: root.sectionHeight

            ColumnLayout {
                anchors.fill: parent

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Est. Time"
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: estimatedTimeText
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }
            }
        }


        //==============================================================
        // DIST HOME
        //==============================================================

        Item {
            width: parent.width
            height: root.sectionHeight

            ColumnLayout {
                anchors.fill: parent

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Dist. Home"
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: activeVehicle ?
                          safe(activeVehicle.distanceToHome.value, 2) + " m"
                          : "--"
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }
            }
        }


        //==============================================================
        // DIST WP
        //==============================================================

        Item {
            width: parent.width
            height: root.sectionHeight

            ColumnLayout {
                anchors.fill: parent

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Dist. WP"
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: activeVehicle ?
                          safe(activeVehicle.distanceToNextWP.value, 2) + " m"
                          : "--"
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }
            }
        }



        //==============================================================
        // ALT AMSL
        //==============================================================

        Item {
            width: parent.width
            height: root.sectionHeight

            ColumnLayout {
                anchors.fill: parent

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Alt. Rel"
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: activeVehicle ?
                          safe(activeVehicle.altitudeRelative.value, 1) + " m"
                          : "--"
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }
            }
        }


        //==============================================================
        // HOR SPEED
        //==============================================================

        Item {
            width: parent.width
            height: root.sectionHeight

            ColumnLayout {
                anchors.fill: parent

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Hor. Speed"
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: activeVehicle ?
                          safe(activeVehicle.airSpeed.value, 1) + " m/s"
                          : "--"
                    color: activeVehicle &&
                           activeVehicle.airSpeed.value > 17
                           ? "red" : "white"
                    font.pointSize: 14
                    font.bold: true
                }
            }
        }


        //==============================================================
        // VERT SPEED
        //==============================================================

        Item {
            width: parent.width
            height: root.sectionHeight

            ColumnLayout {
                anchors.fill: parent

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Vert. Speed"
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: activeVehicle ?
                          safe(activeVehicle.climbRate.value, 1) + " m/s"
                          : "--"
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }
            }
        }

    }
}

