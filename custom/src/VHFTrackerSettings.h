/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#pragma once

#include "SettingsGroup.h"

class VHFTrackerSettings : public SettingsGroup
{
    Q_OBJECT
    
public:
    VHFTrackerSettings(QObject* parent = NULL);

    Q_PROPERTY(Fact* frequency  READ frequency  CONSTANT)
    Q_PROPERTY(Fact* gain       READ gain       CONSTANT)

    Fact* frequency (void);
    Fact* gain      (void);

private:
    SettingsFact* _frequencyFact;
    SettingsFact* _gainFact;
\
    static const char* _settingsGroup;
    static const char* _frequencyFactName;
    static const char* _gainFactName;
};
