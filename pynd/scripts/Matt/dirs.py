"""
List of all usefull directories storing experiment data
"""
import os

DIR_DATA = r"\\vrlescot\EQUIPE_SIGMA\Manip_These_Sassman\Data"

# Raw data
DIR_RAW = os.path.join(DIR_DATA, "RAW")
# ... From simulator
DIR_SIMU = os.path.join(DIR_RAW, "Simu")
DIR_RAW_VIDEO = os.path.join(DIR_RAW, "Videos")

# Documentation, used for pre-processing
DIR_DOC = os.path.join(DIR_DATA, "Doc")

# Processed data
DIR_PROCESSED = os.path.join(DIR_DATA, "Processed")
# ... Basic split of simu data, by subject/scenario
DIR_DATA_SPLIT = os.path.join(DIR_PROCESSED, "Split")
# ... Split with aggragated user IDS, by subject/scenario
DIR_DATA_SIMU = os.path.join(DIR_PROCESSED, "Simu")
# Video data
DIR_DATA_VIDEO = os.path.join(DIR_PROCESSED, "Video")
DIR_DATA_VIDEO_QUADRA = os.path.join(DIR_DATA_VIDEO, "Quadra")
# ... Freeze processing
DIR_FREEZE_OUT = os.path.join(DIR_PROCESSED, "Freeze")

DIR_TOBII = os.path.join(DIR_DATA, "..", "Tobii")