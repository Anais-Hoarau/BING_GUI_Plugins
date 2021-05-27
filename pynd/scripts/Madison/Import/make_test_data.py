import os

# Current raw video location
RAW_VID_DIR = r"T:\MADISON\DATA\IDSCAM\IDSCAM_DROITE_image_out"

# test dir
TEST_DIR = r"D:\derollepot\Desktop\TEST"

for root, dirs, files in os.walk(RAW_VID_DIR):
    for f in files:
        if f.startswith('RecFile_REC_'):
            fname = f.split()[0]
            open(os.path.join(TEST_DIR, f"{fname}"), 'a').close()
