import os
import subprocess
import logging as log
from datetime import datetime as dt
from shutil import rmtree
from scripts.Matt.mutiprocessing_log import LoggingPool

DIR_EXPE = r"I:\MADISON\DATA2\~DATA_TME"
data_to_remove = ['BIOPAC_MP150.resp',
                  'BIOPAC_MP150.trigger_1',
                  'BIOPAC_MP150.trigger_2',
                  'BIOPAC_MP150.trigger_3',
                  'BIOPAC_MP150.trigger_4',
                  'BIOPAC_MP150.trigger_5',
                  'EMPATICA_E4_TXT.outputAscii',
                  'PUPIL_GLASSES.pupil',
                  'PUPIL_GLASSES.fixations']


def clean_rec_file(rec_file: str, data2remove: str):
    """
    Creates backup files for *.rec, *.idy, *.idx files
    Cleans the *.rec file and the *.idy file associated and useless folders according to the data list to remove
    Regenerate the *.idx file associated to the given *.rec file
    """
    root, f = os.path.split(rec_file)
    idy_file = os.path.join(root, f[0:-4] + '.idy')

    # Cleans rec file according to the data list to remove
    clean_file(rec_file, data2remove)
    # Cleans idy file according to the data list to remove
    clean_file(idy_file, data2remove)
    # Change licence information
    change_licence_info(rec_file, 'IFSTTAR LESCOT')
    change_licence_info(idy_file, 'IFSTTAR LESCOT')
    # Cleans folders according to the data list to remove
    clean_folder(root, data2remove)
    # Regenerates the *.idx file associated to the given *.rec file
    regenerate_idx(rec_file)


def clean_file(file: str, data2remove: str):
    """
    Cleans file according to the data list to remove
    """
    if not os.path.exists(file + '_old'):
        os.rename(file, file + '_old')
    file_name = os.path.basename(file)
    log.info(f"Cleaning {file_name} file")
    with open(file + '_old', 'r') as old_file, open(file, 'x') as new_file:
        for line in old_file:
            if not any(data in line for data in data2remove):
                new_file.write(line)
    os.unlink(file + '_old')


def change_licence_info(file: str, new_string: str):
    """
    Change licence information
    """
    if not os.path.exists(file + '_old'):
        os.rename(file, file + '_old')
    file_name = os.path.basename(file)
    log.info(f"Changing licence information for {file_name} file")
    with open(file + '_old', 'r') as old_file, open(file, 'x') as new_file:
        for line in old_file:
            if line.startswith('This product is licensed to: '):
                new_file.write('This product is licensed to: ' + new_string + '.\n')
            else:
                new_file.write(line)
    os.unlink(file + '_old')


def clean_folder(root, data2remove):
    """
    Cleans file according to the data list to remove
    """
    log.info(f"Cleaning folders")
    for data in data2remove:
        folder2remove = os.path.join(root, data.replace('.', '_'))
        if os.path.exists(folder2remove) and os.path.isdir(folder2remove):
            rmtree(folder2remove)


def regenerate_idx(rec_file):
    """
    Regenerates the *.idx file associated to the given *.rec file
    """
    idx_file = rec_file[:-4] + ".idx"
    file_name = os.path.basename(idx_file)
    log.info("Regenerating " + file_name)
    h = subprocess.Popen(["IdxRegeneratorCLI.exe", rec_file])
    h.wait()


def main():
    with LoggingPool('%(asctime)-15s (PID %(process)-5d) [%(levelname)-8s]: %(message)s', level=log.INFO,
                     filename='clean_rec_files.log') as _:
        start_time = dt.now()
        count = 0
        with LoggingPool().make_pool(6) as pool:
            for root, dirs, files in os.walk(DIR_EXPE):
                if "unused" in root.lower():
                    continue
                for f in files:
                    if not f.endswith(".rec"):
                        continue
                    rec_file = os.path.join(root, f)
                    count += 1
                    pool.apply_async(clean_rec_file, (rec_file, data_to_remove))
            pool.close()
            pool.join()
            log.info(f"Cleaned {count} rec files in {dt.now() - start_time}")


if __name__ == '__main__':
    main()
