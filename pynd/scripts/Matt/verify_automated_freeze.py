import os
import matplotlib.pyplot as plt

from dirs import DIR_DATA_SIMU
from utils import Vehicule


def main():
    # Prepating plots
    fig = plt.figure()
    plts = []
    for i in range(2, 7):
        sub_plt = fig.add_subplot(2, 3, i-1)
        sub_plt.grid(True)
        sub_plt.set_title("Car {id}".format(id=i))
        sub_plt.set_xlabel('Long dist (m)')
        sub_plt.set_ylabel('Lat dist (m)')
        plts.append(sub_plt)

    for subject in os.listdir(DIR_DATA_SIMU):
        try:
            ego, *others = Vehicule.load_last_pose(subject, "BAU_Alt_ThierryLikes_changeGreen", *list(range(1,7)))
        except IOError:
            continue

        for i, car in enumerate(others):
            plts[i].plot(ego.dist_long(car),ego.dist_lat(car), 'ro')

    plt.show()


if __name__ == "__main__":
    main()