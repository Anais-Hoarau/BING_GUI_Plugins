import collections
import os
import sys

import matplotlib.pyplot as plt
import numpy as np
from scipy.signal import find_peaks

from pynd import SQLiteTrip

# Append pynd folder to the path
sys.path.append(os.path.abspath(os.path.join(os.getcwd(), os.pardir, os.pardir, os.pardir)))


class RRIntervalRealTime:
    def __init__(self):
        self.biofeedbackType = 'Real'
        self.biofeedbackRatio = 1.1
        self.nValuesAvg = 1
        self.windowSize = 800
        self.idxBuffer = 1
        self.subStep = 32
        self.currentTC = 0
        self.ecgValue = []
        self.ecgValues = collections.deque(maxlen=self.windowSize)
        self.newPeakTC = 0
        self.lastPeakTC = 0
        self.newPeakValue = []
        self.peakValueChanged = 0
        self.peakTCs = []
        self.peakValues = []
        self.peakTCsPredict = []
        self.peakTCsPredictDec = []
        self.peakTCsPredictDecCorrelated = []
        self.peakTCsPredictInc = []
        self.peakTCsPredictIncCorrelated = []
        self.peakTCPredictDiff = []
        self.stim = []
        self.stimCount = 0
        self.stimCountDec = 0
        self.lastStimCountDec = 0
        self.stimCountDecCorrelated = 0
        self.stimCountInc = 0
        self.lastStimCountInc = 0
        self.stimCountIncCorrelated = 0
        self.enforcedPeakCount = 0
        self.errorCount = 0
        self.RRIntervals = []
        self.RRIntervalsAvg = []
        self.bpm = []
        self.correction_threshold = 1.5
        # Find peaks parameters
        self.peakDistance = 500  # Minimal distance between two peaks
        self.peakProm = 1.0  # Minimal prominence of a peak
        self.peakWidth = [10, 50]   # Minimal and maximal width of a peak
        self.peakWLen = self.windowSize   # Maximum window size on which to search for peaks
        self.peakPlatSize = [1, 2]  # Minimal and maximal plateau size of a peak

    def core(self):
        # Inputs
        self.ecgValues.append(self.ecgValue[0])

        # Initialize variables
        biofeedback_cond = False
        self.peakValueChanged = 0
        self.stim.append(0)

        # Correction step
        if self.RRIntervals and \
                np.diff([self.peakTCs[-1], self.currentTC]) > self.correction_threshold * self.RRIntervals[-1]:
            self.newPeakValue = self.peakValues[-1]
            self.newPeakTC = self.peakTCs[-1] + self.RRIntervals[-1]

        # Find peaks step
        if np.mod(self.currentTC, self.windowSize / self.subStep) == 0 and self.currentTC >= self.windowSize:
            ecg_values = list(self.ecgValues)
            peak_tc, _ = find_peaks(ecg_values, distance=self.peakDistance, prominence=self.peakProm,
                                    width=self.peakWidth, wlen=self.peakWLen, plateau_size=self.peakPlatSize)
            if peak_tc.size >= 1:
                self.newPeakTC = int(peak_tc[0] + (self.idxBuffer - 1) * self.windowSize / self.subStep)
                self.newPeakValue = ecg_values[int(peak_tc[0])]

            if self.lastPeakTC == 0 or \
                    (self.newPeakTC != self.lastPeakTC and self.newPeakTC - self.lastPeakTC > self.peakDistance):
                self.peakValueChanged = 1
                self.peakTCs.append(self.newPeakTC)
                self.peakValues.append(self.newPeakValue)

                if len(self.peakTCs) > 1:
                    self.RRIntervals.append(np.diff([self.peakTCs[-2], self.peakTCs[-1]]))
                    if self.peakTCsPredict:
                        self.peakTCPredictDiff.append(np.diff([self.peakTCs[-1], self.peakTCsPredict[-1]]))
                        if self.peakTCPredictDiff[-1] > 200:
                            self.errorCount += 1
                            print('Error count = ' + str(self.errorCount))

                self.lastPeakTC = self.newPeakTC

            self.idxBuffer = self.idxBuffer + 1

        if self.RRIntervals and self.peakValueChanged:
            self.peakTCsPredict.append(self.peakTCs[-1] + self.RRIntervals[-1])
            self.peakTCsPredictDec.append(int(int(self.peakTCsPredict[-1]) * self.biofeedbackRatio))
            self.peakTCsPredictInc.append(int(int(self.peakTCsPredict[-1]) / self.biofeedbackRatio))
            self.bpm.append(60000 / self.RRIntervals[-1])

        # Biofeedback condition
        if self.biofeedbackType == 'Real' and len(self.peakTCsPredict) >= self.stimCount + 1:
            biofeedback_cond = self.currentTC == self.peakTCsPredict[self.stimCount]
        elif self.biofeedbackType == 'Decreased' and len(self.peakTCsPredictDec) >= self.stimCount + 1:
            biofeedback_cond = self.currentTC == self.peakTCsPredictDec[self.stimCount]
        elif self.biofeedbackType == 'Increased' and len(self.peakTCsPredictInc) >= self.stimCount + 1:
            biofeedback_cond = self.currentTC == self.peakTCsPredictInc[-1]

        if biofeedback_cond:
            self.stim.append(1)
            self.stimCount += 1

        self.currentTC += 1

        return self.peakValueChanged, self.peakTCs, self.peakValues, self.RRIntervals, self.bpm, \
               self.stim, self.stimCount, self.errorCount

    def stimulus_sender(self):
        # Biofeedback 'Real'
        if len(self.peakTCsPredict) >= self.stimCount + 1 \
                and self.currentTC == self.peakTCsPredict[self.stimCount]:
            self.stimCount += 1
            if self.biofeedbackType == 0:
                self.stim = 1
        # Biofeedback 'Decreased'
        if len(self.peakTCsPredictDec) >= self.stimCountDec + 1 \
                and self.currentTC == self.peakTCsPredictDec[self.stimCountDec]:
            self.stimCountDec += 1
            if self.biofeedbackType == 1:
                self.stim = 1
                if len(self.peakTCsPredictDec) >= 2:
                    print('RRInterval = ' + str(int(self.RRIntervals[-1])) +
                          ' | peakTCsPredictDecDiff = ' + str(self.peakTCsPredictDec[-1] - self.peakTCsPredictDec[-2]))
        # Biofeedback 'Decreased Correlated'
        if len(self.peakTCsPredictDecCorrelated) >= self.stimCountDecCorrelated + 1 \
                and self.currentTC == self.peakTCsPredictDecCorrelated[self.stimCountDecCorrelated]:
            self.stimCountDecCorrelated += 1
            if self.biofeedbackType == 2:
                self.stim = 1
        # Biofeedback 'Increased'
        if len(self.peakTCsPredictInc) >= self.stimCountInc + 1 \
                and self.currentTC == self.peakTCsPredictInc[self.stimCountInc]:
            self.stimCountInc += 1
            if self.biofeedbackType == 3:
                self.stim = 1
                if len(self.peakTCsPredictInc) >= 2:
                    print('RRInterval = ' + str(int(self.RRIntervals[-1])) +
                          ' | peakTCsPredictIncDiff = ' + str(self.peakTCsPredictInc[-1] - self.peakTCsPredictInc[-2]))
        # Biofeedback 'Increased Correlated'
        if len(self.peakTCsPredictIncCorrelated) >= self.stimCountIncCorrelated + 1 \
                and self.currentTC == self.peakTCsPredictIncCorrelated[self.stimCountIncCorrelated]:
            self.stimCountIncCorrelated += 1
            if self.biofeedbackType == 4:
                self.stim = 1

    def RRInt_averager(self):
        rr_intervals_avg = []
        for idx in range(self.nValuesAvg, -1, -1):
            if len(self.RRIntervals) >= idx:
                rr_intervals_avg = int(np.mean(self.RRIntervals[-idx:]))
                break
        return rr_intervals_avg

    def test_ecg(self):

        # Load data
        trip_path = '//vrlescot/MADISON/DATA2/Passation_08/rtmaps/Test/' \
                   '20190513_161348_RecFile_REC/RecFile_REC_20190513_161348.trip'
        with SQLiteTrip(trip_path, 0.04, False) as trip:
            ecg_values = trip.get_all_data_occurences('Biopac_MP150').get_variables_values('ecg')
            ecg_values = list(ecg_values)

            # Loop on data
            for currentTC, self.ecgValue in enumerate(ecg_values):
                RRIntervalRealTime.core(self)

                # Display indicators
                if self.RRIntervals and self.peakValueChanged == 1:
                    print("Current TC : " + str(currentTC) +
                          " | RR interval : " + str(int(self.RRIntervals[-1])) +
                          " | bpm : " + str(float(self.bpm[-1])) +
                          " | nombre de stim = " + str(self.stimCount) +
                          " | nombre d'erreurs = " + str(self.errorCount))

                # Plot results
                if np.mod(self.stimCount, 200) == 0 and self.stimCount > 1:
                    fig, axs = plt.subplots(2, 1)
                    axs[0].plot(ecg_values[0:currentTC])
                    axs[0].plot(self.stim)
                    axs[0].plot(self.peakTCs, self.peakValues, 'rv')
                    axs[0].grid(True)
                    axs[1].step(self.peakTCs[0:-1], [x / 10 for x in self.RRIntervals], 'g')
                    axs[1].step(self.peakTCs[0:-1], self.bpm, 'm')
                    axs[1].grid(True)
                    plt.show()
                    plt.close('all')


def main():
    RRIntervalRealTime().test_ecg()


if __name__ == '__main__':
    main()
