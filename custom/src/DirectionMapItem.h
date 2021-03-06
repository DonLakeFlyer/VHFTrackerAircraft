#pragma once

#include "QmlComponentInfo.h"

#include <QVariantList>
#include <QGeoCoordinate>

class DirectionMapItem : public QmlComponentInfo
{
    Q_OBJECT

    Q_PROPERTY(QGeoCoordinate   coordinate      MEMBER _coordinate      CONSTANT)
    Q_PROPERTY(double           heading         MEMBER _heading         CONSTANT)
    Q_PROPERTY(double           signalStrength  MEMBER _signalStrength  CONSTANT)

public:
    DirectionMapItem(const QGeoCoordinate& coordinate, double heading, double signalStrength, QObject* parent = NULL);
    ~DirectionMapItem();

private:
    QGeoCoordinate  _coordinate;
    double          _heading;
    double          _signalStrength;
};
