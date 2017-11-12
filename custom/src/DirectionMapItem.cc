#include "DirectionMapItem.h"

#include <QColor>
#include <QDebug>

DirectionMapItem::DirectionMapItem(const QGeoCoordinate& coordinate, double heading, double signalStrength, QObject* parent)
    : QmlComponentInfo  (QString(), QUrl::fromUserInput("qrc:/qml/DirectionMapItem.qml"), QUrl(), parent)
    , _coordinate       (coordinate)
    , _heading          (heading)
    , _signalStrength   (signalStrength)
{

}

DirectionMapItem::~DirectionMapItem()
{

}
