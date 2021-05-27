"""
Processes and exports data for the "5m" analysis
"""
import logging as log
import os
import csv

from dirs import DIR_DOC, DIR_DATA_SIMU, DIR_PROCESSED
from utils import load_structured_csv, Vehicule, FreezeStaticData, FreezeMove, FreezeResult, TooManyUserChanges, sort_by


def main():
    log.basicConfig(format='%(asctime)-15s [%(levelname)-8s]: %(message)s', level=log.INFO)
    results = []
    moves = sort_by(list(FreezeMove.load_all()), "scenario")
    freezes = sort_by(list(FreezeStaticData.load_all()), "scenario")
    # For all valid scenarios
    for scenario in load_structured_csv(os.path.join(DIR_DOC, "5mScenarios.csv"), str, has_header=False, delim=","):
        log.info("Processing {scenario}".format(scenario=scenario))
        move = moves[scenario]
        freeze = freezes[scenario]
        # Check all subject
        for subject in os.listdir(DIR_DATA_SIMU):
            if "test" in subject:
                continue
            try:
                # Try to load subject data
                pre_freeze, ego = Vehicule.load_last_pose(subject, scenario, freeze.car_id, 1)
                user_result = FreezeResult.load(subject, scenario)
                results_count = 1 if user_result is not None else 0
            except IOError:
                # Subject has no matching scenario, probably due to a simulator crash/demo
                continue
            except TooManyUserChanges as e:
                user_result = None
                results_count = e.changes

            ego_to_user_car_long = 0
            ego_to_user_car_lat = 0
            ego_to_user_car = 0
            mesh_match = False
            time_to_answer = 0
            if user_result:
                dt = user_result.vehicule.timestamp - pre_freeze.timestamp
                time_to_answer = dt.total_seconds()
                if time_to_answer < 0:
                    log.error(
                        "In {scenario}, {subject} answered {time_to_answer:.2f}s before the freeze occured".format(
                            scenario=scenario,
                            subject=subject,
                            time_to_answer=-time_to_answer))
                    continue
                ego_to_user_car_long = ego.dist_long(user_result.vehicule)
                ego_to_user_car_lat = ego.dist_lat(user_result.vehicule)
                ego_to_user_car = ego.dist(user_result.vehicule)
                mesh_match = user_result.mesh == freeze.mesh

            pre_to_postfreeze = pre_freeze.dist_long(move.vehicule)
            ego_to_prefreeze = ego.dist_long(pre_freeze)
            ego_to_postfreeze = ego.dist_long(move.vehicule)
            result = [scenario,
                      subject,
                      results_count,
                      pre_to_postfreeze,
                      ego_to_prefreeze,
                      ego_to_postfreeze,
                      ego.speed_long(),
                      pre_freeze.speed_long(),
                      time_to_answer,
                      ego_to_user_car_long,
                      ego_to_user_car_lat,
                      # ego_to_user_car,
                      mesh_match]
            results.append(result)

    header = ["scenario",
              "subject",
              "results count",
              "pre to postfreeze long dist (m)",
              "ego to prefreeze long dist (m)",
              "ego to postfreeze long dist (m)",
              "ego long speed (m.s-1)",
              "pre freeze long speed (m.s-1)",
              "time to answer (s)",
              "ego to user added car long dist (m)",
              "ego to user added car lat dist (m)",
              # "ego to user added car dist (m)",
              "mesh matches (bool)"]

    assert (len(header) == len(results[0]))

    res_fn = os.path.join(DIR_PROCESSED, "freeze_results_5m.csv")
    with open(res_fn, 'w+') as subject_res:
        subject_res_writer = csv.writer(subject_res, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL,
                                        lineterminator='\n')
        subject_res_writer.writerow(header)
        for r in results:
            subject_res_writer.writerow(r)


if __name__ == "__main__":
    main()
