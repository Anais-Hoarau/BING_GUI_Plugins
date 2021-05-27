"""
This script is a test to load a participant driving situation and parse it according to several criteria
"""
import os
import logging as log

import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime
from dateutil import relativedelta
import seaborn as sns

import pynd
import pandas as pd

#TRIP_FILE_PATH = r"\\vrlescot\EQUIPE_SIGMA\These_Jonathan\Experiment_data\10\Scenario_prototype_2\1.400000s\20180801_144334_RecFile_2\RecFile_2_20180801_144334.trip"
#TRIP_FILE_PATH = r"\\vrlescot\EQUIPE_SIGMA\These_Jonathan\Experiment_data\10\Scenario_prototype_2\2.600000s\20180801_150750_RecFile_2\RecFile_2_20180801_150750.trip"
TRIP_FILE_PATH = r"\\vrlescot\EQUIPE_SIGMA\These_Jonathan\Experiment_data\10\Scenario_prototype_2\2.600000s\20180801_152754_RecFile_2\RecFile_2_20180801_152754.trip"
#TRIP_FILE_PATH = r"\\vrlescot\EQUIPE_SIGMA\These_Jonathan\Experiment_data\24\Scenario_prototype_2\2.400000s\20180918_090033_RecFile_2\RecFile_2_20180918_090033.trip"

MetaTripData = {}

with pynd.SQLiteTrip(TRIP_FILE_PATH, 0.04, False) as trip:
    try:
        MetaTripData = {'Participant number': [trip.get_attribute("participant_id")],
                        'Gap size': [trip.get_attribute("gap")],
                        'Mode de conduite': [trip.get_attribute("scenario")],
                        'Numero de passage': [trip.get_attribute("num_passage")]}
        MetaTripData_df = pd.DataFrame(MetaTripData)
        result = trip.get_all_data_occurences('Ego_Car')
        Ego_XY_Position_df = pd.DataFrame()
        for variable_name in result.get_variable_names():
            data_list = pd.Series(result.get_variable_values(variable_name))
            Ego_XY_Position_df[variable_name] = data_list.values
        
        print(list(trip.get_all_event_occurences('EventDebug_1').get_variables_values('timecode', 'Scenario_stage')))
#        print(list(trip.get_all_event_occurences('EventDebug_1')))



    except pynd.MetaInfosException:
        log.warning(f"Trip {TRIP_FILE_PATH} does not have meta trip data")



sns.lineplot(x='timecode', y='Vehicle coordinate Y', data=Ego_XY_Position_df)
plt.hlines(y=-4.75, xmin=0, xmax=100, linestyles='dashed')


#################################
##          Functions          ##
#################################

########### Function that creates a data frame based on a trip data table
def trip_data_to_df(trip_file_path, table_name):
    data_frame = pd.DataFrame()
    temporary_dict = {}
    with pynd.SQLiteTrip(trip_file_path, 0.04, False) as trip:
        result = trip.get_all_data_occurences(table_name)
        for key in result.get_variable_names():
            temporary_dict[str(key)] = result.get_variable_values(key)
        data_frame = pd.DataFrame.from_dict(temporary_dict)
    return data_frame


########### Function that creates a data frame based on an event data table
def trip_events_to_df(trip_file_path, table_name):
    data_frame = pd.DataFrame()
    temporary_dict = {}
    with pynd.SQLiteTrip(trip_file_path, 0.04, False) as trip:
        result = trip.get_all_event_occurences(table_name)
        for key in result.get_variable_names():
            temporary_dict[str(key)] = result.get_variable_values(key)
        data_frame = pd.DataFrame.from_dict(temporary_dict)
    return data_frame


##### Function than finds the closest value to mid line Y coordinate
def closest_value(table_name, y_coord_cible):
    mid_line_y_coord = y_coord_cible
    row = table_name.iloc[(table_name['Vehicle coordinate Y']-mid_line_y_coord).abs().argsort()[:1]]
    return row


##### Generic function than finds the closest value to a target value in a target column
def closest_value_generic(table_name, target_value, target_column):
    row = table_name.iloc[(table_name[target_column]-target_value).abs().argsort()[:1]]
    return row


target2 = closest_value_generic(table_name=Ego_df_merged, target_column='Vehicle coordinate Y', target_value=-4.75)

Ego_df = trip_data_to_df(trip_file_path=TRIP_FILE_PATH, table_name='Ego_car')
#Ego_df['timecode_bis'] = pd.to_datetime(Ego_df['timecode'], unit='s')
#Ego_df_indexed = Ego_df.set_index('timecode_bis').copy()

computed_values_df = trip_data_to_df(trip_file_path=TRIP_FILE_PATH, table_name='Computed_values')
#computed_values_df['timecode_bis'] = pd.to_datetime(computed_values_df['timecode'], unit='s')
#computed_values_df.dtypes
#computed_values_df_indexed = computed_values_df.set_index('timecode_bis').copy()

#Ego_df_merged = Ego_df.merge(computed_values_df, on=['timecode_bis', 'timecode_bis'], how='outer')
#Ego_df_merged_2 = Ego_df_merged.set_index('timecode_bis').sort_index()
#Ego_df_merged_2.dtypes
#
#Ego_df_merged_2['Speed X'] = Ego_df_merged_2['Speed X'].interpolate()
#Ego_df_merged_2['Speed X'] = Ego_df_merged_2['Speed X'].interpolate()
#Ego_df_merged_2['Speed X'] = Ego_df_merged_2['Speed X'].interpolate(method='index')
#Ego_df_merged_2['Speed Y'] = Ego_df_merged_2['Speed Y'].interpolate(method='index')
#Ego_df_merged_2['timecode_x'] = Ego_df_merged_2['timecode_x'].interpolate(method='index')



Ego_df_merged = Ego_df.merge(computed_values_df, on=['timecode', 'timecode'], how='outer')
Ego_df_merged = Ego_df_merged.set_index('timecode').sort_index()



Ego_df_merged.dtypes

Ego_df_merged['Speed X'] = Ego_df_merged['Speed X'].interpolate(method='index')
Ego_df_merged['Speed Y'] = Ego_df_merged['Speed Y'].interpolate(method='index')
Ego_df_merged['Vehicle coordinate X'] = Ego_df_merged['Vehicle coordinate X'].interpolate(method='index')
Ego_df_merged['Vehicle coordinate Y'] = Ego_df_merged['Vehicle coordinate Y'].interpolate(method='index')

Ego_df_merged = Ego_df_merged.reset_index()

#sns.lineplot(x='Vehicle coordinate X', y='timecode', data=Ego_df_merged_2)
#plt.hlines(y=-4.75, xmin=500, xmax=3000, linestyles='dashed')
#plt.hlines(y=0, xmin=500, xmax=3000)
#plt.hlines(y=-9.5, xmin=500, xmax=3000)
#sns.lineplot(x='Vehicle coordinate X', y='Ego_Speed', data=Ego_df_merged_2)
#sns.lineplot(x='Vehicle coordinate X', y='Speed Y', data=Ego_df_merged_2)
#sns.lineplot(x='Vehicle coordinate X', y='Ego_Acceleration', data=Ego_df_merged_2)

plt.subplots(figsize=(9, 8))
sns.lineplot(x='timecode',y='Vehicle coordinate Y', data=Ego_df_merged)
plt.hlines(y=-4.75, xmin=1.5, xmax=110, linestyles='dashed')
plt.hlines(y=-1.5, xmin=1.5, xmax=110)
plt.hlines(y=-8.5, xmin=1.5, xmax=110)

#sns.lineplot(x='timecode_x', y='Ego_Speed', data=Ego_df_merged_2)
sns.lineplot(x='timecode', y='Ego_Acceleration', data=Ego_df_merged)





event_df = trip_events_to_df(trip_file_path=TRIP_FILE_PATH, table_name='EventDebug_1')
event_df['timecode_bis'] = pd.to_datetime(event_df['timecode'], unit='s')
Ego_event_merged = Ego_df.merge(event_df, on=['timecode_bis', 'timecode_bis'], how='outer')
Ego_event_merged = Ego_event_merged.set_index('timecode_bis').sort_index()


#### Slice data

with pynd.SQLiteTrip(TRIP_FILE_PATH, 0.04, False) as trip:
        result = trip.get_all_event_occurences('EventDebug_1')
        for timecode, stage in result.get_variables_values('timecode','Scenario_stage'):
            if 'Gap Com' in stage :
                start_time = timecode - 5.0
            elif 'End' in stage :
                end_time = timecode
        result = trip.get_data_occurences_in_time_interval(data_name='Ego_Car', start_time=start_time, end_time=end_time)
        temporary_dict = {}
        for key in result.get_variable_names():
            temporary_dict[str(key)] = result.get_variable_values(key)
        data_frame_sliced = pd.DataFrame.from_dict(temporary_dict)
        sns.lineplot(x='timecode', y='Vehicle coordinate Y', data=data_frame_sliced)
        plt.vlines(x=(start_time+10), ymin=-9, ymax=-1.0, colors='Grey')
        plt.hlines(y=-4.75, xmin=start_time, xmax=end_time, linestyles='dashed')
        plt.hlines(y=-1.5, xmin=start_time, xmax=end_time)
        plt.hlines(y=-8.5, xmin=start_time, xmax=end_time)
        
with pynd.SQLiteTrip(TRIP_FILE_PATH, 0.04, False) as trip:
        result = trip.get_all_event_occurences('EventDebug_1')
        for timecode, stage in result.get_variables_values('timecode','Scenario_stage'):
            if 'Gap Com' in stage :
                start_time = timecode
            elif 'End' in stage :
                end_time = timecode
        result = trip.get_data_occurences_in_time_interval(data_name='Ego_Car', start_time=start_time, end_time=end_time)
        temporary_dict = {}
        for key in result.get_variable_names():
            temporary_dict[str(key)] = result.get_variable_values(key)
        data_frame_sliced_3 = pd.DataFrame.from_dict(temporary_dict)
        sns.lineplot(x='Vehicle coordinate X', y='Vehicle coordinate Y', data=data_frame_sliced_3)
        sns.lineplot(x='Vehicle coordinate X', y='Vehicle coordinate Y', data=data_frame_sliced_2)
        sns.lineplot(x='Vehicle coordinate X', y='Vehicle coordinate Y', data=data_frame_sliced)
        plt.hlines(y=-5.00, xmin=2250, xmax=2600, linestyles='dashed')
        plt.hlines(y=-1.5, xmin=2250, xmax=2600)
        plt.hlines(y=-8.5, xmin=2250, xmax=2600)







Ego_df_merged['Ego_Speed'] = Ego_df_merged['Ego_Speed'].interpolate(me)
Ego_df_merged['Ego_Acceleration'] = Ego_df_merged['Ego_Acceleration'].interpolate()
Ego_df_merged['Ego_to_GO_thw'] = Ego_df_merged['Ego_to_GO_thw'].interpolate()
Ego_df_merged['Ego_to_GO_ttc'] = Ego_df_merged['Ego_to_GO_ttc'].interpolate()
Ego_df_merged['GC_to_Ego_thw'] = Ego_df_merged['GC_to_Ego_thw'].interpolate()
Ego_df_merged['GC_to_Ego_ttc'] = Ego_df_merged['GC_to_Ego_ttc'].interpolate()

target = closest_value(table_name=Ego_df_merged, y_coord_cible=-4.75)
s_time = float(target['timecode']-10.0)
e_time = float(target['timecode']+10.0)




with pynd.SQLiteTrip(TRIP_FILE_PATH, 0.04, False) as trip:
        result = trip.get_data_occurences_in_time_interval(data_name='Ego_Car', start_time=s_time, end_time=e_time)
        temporary_dict = {}
        for key in result.get_variable_names():
            temporary_dict[str(key)] = result.get_variable_values(key)
        data_frame_sliced_20s = pd.DataFrame.from_dict(temporary_dict)


mask = (Ego_df_merged_2['timecode_x'] >= s_time) & (Ego_df_merged_2['timecode_x'] <= e_time)
Ego_df_merged_2_cut = Ego_df_merged_2.loc[mask]



sns.lineplot(x='Vehicle coordinate X', y='Vehicle coordinate Y', data=data_frame_sliced_20s)
plt.hlines(y=-5.00, xmin=2250, xmax=2600, linestyles='dashed')
plt.hlines(y=-1.5, xmin=2250, xmax=2600)
plt.hlines(y=-8.5, xmin=2250, xmax=2600)
        

min_thw_df = Ego_df_merged_2_cut.loc[Ego_df_merged_2['GC_to_Ego_thw'] == Ego_df_merged_2_cut['GC_to_Ego_thw'].min()]
min_thw = min_thw_df['Vehicle coordinate X'][0]
min_ttc_df = Ego_df_merged_2_cut.loc[Ego_df_merged_2['GC_to_Ego_ttc'] == Ego_df_merged_2_cut['GC_to_Ego_ttc'].min()]
min_ttc = min_ttc_df['Vehicle coordinate X'][0]


sns.lineplot(x='Vehicle coordinate X', y='Vehicle coordinate Y', data=Ego_df_merged_2_cut)
#sns.lineplot(x='Vehicle coordinate X', y='GC_to_Ego_thw', data=Ego_df_merged_2_cut)
#sns.lineplot(x='Vehicle coordinate X', y='GC_to_Ego_ttc', data=Ego_df_merged_2_cut)
#sns.lineplot(x='Vehicle coordinate X', y='Ego_to_GO_thw', data=Ego_df_merged_2_cut)
#sns.lineplot(x='Vehicle coordinate X', y='Ego_to_GO_ttc', data=Ego_df_merged_2_cut)
plt.vlines(x=min_thw, ymin=-8.5, ymax=-1.5)
plt.vlines(x=min_ttc, ymin=-8.5, ymax=-1.5, colors='blue')
plt.hlines(y=-5.00, xmin=2250, xmax=2600, linestyles='dashed')
plt.hlines(y=-1.5, xmin=2250, xmax=2600)
plt.hlines(y=-8.5, xmin=2250, xmax=2600)

test_mask = Ego_event_merged[Ego_event_merged['Scenario_stage'] == 'Gap Comming \\n']

#pupil_data = trip_data_to_df(trip_file_path = TRIP_FILE_PATH, table_name='PUPIL_GLASSES_gaze')
#sns.lineplot(x='timecode', y='timestamp', data=pupil_data)
#sns.lineplot(x=range(100), y=range(100))



####################################################################################################################################
####################################################################################################################################
####################################################################################################################################

