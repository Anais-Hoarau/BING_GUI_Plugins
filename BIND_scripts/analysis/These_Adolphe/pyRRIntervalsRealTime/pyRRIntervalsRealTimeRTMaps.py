import rtmaps.types
import numpy as np
from scipy.signal import find_peaks
import collections
import rtmaps.core as rt
import rtmaps.reading_policy
from rtmaps.base_component import BaseComponent  # base class


# Python class that will be called from RTMaps.
class rtmaps_python(BaseComponent):
    def __init__(self):
        BaseComponent.__init__(self)  # call base class constructor
        self.biofeedbackType = ''
        self.biofeedbackRatio = 1.1
        self.nValuesAvg = 1
        self.windowSize = 800
        self.idxBuffer = 1
        self.subStep = 32
        self.currentTC = 0
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
        self.stim = 0
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

    def Dynamic(self):
        self.add_input("ecg_value", rtmaps.types.ANY)  # define input
        self.add_input("correction_threshold", rtmaps.types.ANY)  # define input
        self.add_input("prominence", rtmaps.types.ANY)  # define input
        self.add_property('Biofeedback_Type',
                          '5|0|Real|Decreased|Decreased_Correlated|Increased|Increased_Correlated',
                          rtmaps.types.ENUM)
        self.add_property('Biofeedback_Ratio', 1.1)
        self.add_property('nValues_Avg', 1)
        self.add_property('SubStep_window', 32)
        self.add_output("peak", rtmaps.types.AUTO)  # , buffer_size = 128)  # define output
        self.add_output("stim", rtmaps.types.AUTO)  # , buffer_size = 128)  # define output
        self.add_output("diff", rtmaps.types.AUTO)  # , buffer_size = 128)  # define output
        self.add_output("diff_mean", rtmaps.types.AUTO)  # , buffer_size = 128)  # define output
        self.add_output("RRInt", rtmaps.types.AUTO)  # , buffer_size = 128)  # define output
        self.add_output("HR", rtmaps.types.AUTO)  # , buffer_size = 128)  # define output

# Birth() will be called once at diagram execution startup
    def Birth(self):
        self.biofeedbackType = ''
        self.biofeedbackRatio = 1.1
        self.nValuesAvg = 1
        self.windowSize = 800
        self.idxBuffer = 1
        self.subStep = 32
        self.currentTC = 0
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
        self.stim = 0
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

    # Core() is called every time you have a new input
    def Core(self):
        # Inputs
        ecg_value = self.inputs["ecg_value"].ioelt  # create an ioelt from the ecg input
        self.ecgValues.append(ecg_value.data)  # adds the current ecg value to the buffer
        correction_threshold = self.inputs["correction_threshold"].ioelt  # create an ioelt from the input
        if correction_threshold:
            self.correction_threshold = correction_threshold.data
        peak_prom = self.inputs["prominence"].ioelt  # create an ioelt from the input
        if peak_prom:
            self.peakProm = peak_prom.data
        biofeedback_ratio = self.properties["Biofeedback_Ratio"].data
        self.subStep = self.properties["SubStep_window"].data

        # Initialize variables
        self.peakValueChanged = 0
        self.stim = 0

        # Correction step
        if self.RRIntervals and \
                np.diff([self.peakTCs[-1], self.currentTC]) > self.correction_threshold * self.RRIntervals[-1]:
            self.newPeakTC = self.peakTCs[-1] + rtmaps_python.RRInt_averager(self)
            self.newPeakValue = self.peakValues[-1]
            self.enforcedPeakCount += 1
            print('Enforced peak count = ' + str(self.enforcedPeakCount))

        # Peak detection
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
                        # output peakTCPredictDiff and peakTCPredictDiffMean
                        self.outputs["diff"].write(str(int(abs(self.peakTCPredictDiff[-1]))))
                        self.outputs["diff_mean"].write(str(int(np.mean([abs(ele) for ele in self.peakTCPredictDiff]))))

                        if self.peakTCPredictDiff[-1] > 200:
                            self.errorCount += 1
                            print('Error count = ' + str(self.errorCount))

                self.lastPeakTC = self.newPeakTC

            self.idxBuffer += 1

        # Peak prediction (Biofeedback type : Real)
        if self.RRIntervals and self.peakValueChanged == 1:
            self.peakTCsPredict.append(self.peakTCs[-1] + rtmaps_python.RRInt_averager(self))
            # Replace previous peak Predict timecode if peak detected before prediction
            if len(self.peakTCsPredict) >= 2 and self.peakTCs[-1] < self.peakTCsPredict[-2]:
                self.peakTCsPredict[-2] = self.currentTC
            self.peakTCsPredictDecCorrelated.append(int(self.peakTCsPredict[-1] +
                                                        self.RRIntervals[-1] * (biofeedback_ratio-1)))
            self.peakTCsPredictIncCorrelated.append(int(self.peakTCsPredict[-1] -
                                                        self.RRIntervals[-1] * (biofeedback_ratio-1)))
            self.bpm.append(60000 / self.RRIntervals[-1])  # Update HR (bpm)
            self.peakDistance = int(60000 / (int(np.mean(self.bpm[-2:])) * 1.5))  # Adaptive peak distance based on HR
            self.outputs["peak"].write(self.peakValues[-1])  # output peak value detected
            self.outputs["RRInt"].write(self.RRIntervals[-1] / 1000)  # output last RR_Interval value
            self.outputs["HR"].write(self.bpm[-1])  # output last bpm value

        # Peak prediction for biofeedback 'Decreased'
        if not self.peakTCsPredictDec and self.peakTCsPredict and self.peakValueChanged == 1:
            self.peakTCsPredictDec.append(self.peakTCsPredict[-1])
        elif self.peakTCsPredictDec and self.lastStimCountDec != self.stimCountDec:
            self.peakTCsPredictDec.append(int(self.peakTCsPredictDec[-1] + self.RRIntervals[-1] * biofeedback_ratio))
            self.lastStimCountDec = self.stimCountDec

        # Peak prediction for biofeedback 'Increased'
        if not self.peakTCsPredictInc and self.peakTCsPredict and self.peakValueChanged == 1:
            self.peakTCsPredictInc.append(self.peakTCsPredict[-1])
        elif self.peakTCsPredictInc and self.lastStimCountInc != self.stimCountInc:
            self.peakTCsPredictInc.append(int(self.peakTCsPredictInc[-1] + self.RRIntervals[-1] / biofeedback_ratio))
            self.lastStimCountInc = self.stimCountInc

        rtmaps_python.stimulus_sender(self)  # send stimulus
        self.outputs["stim"].write(self.stim)  # output biofeedback stimulation
        self.currentTC += 1

    def stimulus_sender(self):
        # Biofeedback 'Real'
        if len(self.peakTCsPredict) >= self.stimCount + 1 \
                and self.currentTC == self.peakTCsPredict[self.stimCount]:
            self.stimCount += 1
            if self.properties["Biofeedback_Type"].data == 0:
                self.stim = 1
        # Biofeedback 'Decreased'
        if len(self.peakTCsPredictDec) >= self.stimCountDec + 1 \
                and self.currentTC == self.peakTCsPredictDec[self.stimCountDec]:
            self.stimCountDec += 1
            if self.properties["Biofeedback_Type"].data == 1:
                self.stim = 1
                if len(self.peakTCsPredictDec) >= 2:
                    print('RRInterval = ' + str(int(self.RRIntervals[-1])) +
                          ' | peakTCsPredictDecDiff = ' + str(self.peakTCsPredictDec[-1] - self.peakTCsPredictDec[-2]))
        # Biofeedback 'Decreased Correlated'
        if len(self.peakTCsPredictDecCorrelated) >= self.stimCountDecCorrelated + 1 \
                and self.currentTC == self.peakTCsPredictDecCorrelated[self.stimCountDecCorrelated]:
            self.stimCountDecCorrelated += 1
            if self.properties["Biofeedback_Type"].data == 2:
                self.stim = 1
        # Biofeedback 'Increased'
        if len(self.peakTCsPredictInc) >= self.stimCountInc + 1 \
                and self.currentTC == self.peakTCsPredictInc[self.stimCountInc]:
            self.stimCountInc += 1
            if self.properties["Biofeedback_Type"].data == 3:
                self.stim = 1
                if len(self.peakTCsPredictInc) >= 2:
                    print('RRInterval = ' + str(int(self.RRIntervals[-1])) +
                          ' | peakTCsPredictIncDiff = ' + str(self.peakTCsPredictInc[-1] - self.peakTCsPredictInc[-2]))
        # Biofeedback 'Increased Correlated'
        if len(self.peakTCsPredictIncCorrelated) >= self.stimCountIncCorrelated + 1 \
                and self.currentTC == self.peakTCsPredictIncCorrelated[self.stimCountIncCorrelated]:
            self.stimCountIncCorrelated += 1
            if self.properties["Biofeedback_Type"].data == 4:
                self.stim = 1

    def RRInt_averager(self):
        rr_intervals_avg = []
        for idx in range(self.properties["nValues_Avg"].data, -1, -1):
            if len(self.RRIntervals) >= idx:
                rr_intervals_avg = int(np.mean(self.RRIntervals[-idx:]))
                break
        return rr_intervals_avg

# Death() will be called once at diagram execution shutdown
    def Death(self):
        pass
