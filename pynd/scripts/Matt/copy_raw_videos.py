"""
Scripts to copy all raw quadravision videos from the backup hard drive to the server
"""
import os
import logging as log

from dirs import DIR_RAW_VIDEO


def main():
    log.basicConfig(format='%(asctime)-15s [%(levelname)-8s]: %(message)s', level=log.INFO)
    d = r"G:\Matt\Participants"
    for subject in os.listdir(d):
        dir_subject = os.path.join(d, subject)
        for root, dirs, files in os.walk(dir_subject):
            for f in files:
                if f.endswith(".mpg"):
                    src = os.path.join(root, f)
                    dst = os.path.join(DIR_RAW_VIDEO, subject)
                    try:
                        os.makedirs(dst)
                    except OSError:
                        pass
                    if os.path.exists(os.path.join(dst, f)):
                        log.info(f'{f} already exists for subject {subject}')
                        continue
                    else:
                        log.info(f'Copying {f} for subject {subject}')
                        os.system(f'xcopy "{src}" "{dst}"')


if __name__ == "__main__":
    main()