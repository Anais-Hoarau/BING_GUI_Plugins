from tkinter import *
from tkinter import ttk
from tkinter import font
import datetime

global endTime


class FullScreenApp(object):
    def __init__(self, master, **kwargs):
        self.master=master
        pad = 3
        self._geom = '200x200+0+0'
        master.geometry("{0}x{1}+1913+0".format(
            master.winfo_screenwidth()-pad, master.winfo_screenheight()-pad))
        master.bind('<Escape>', self.toggle_geom)

    def toggle_geom(self, event):
        geom = self.master.winfo_geometry()
        print(geom, self._geom)
        self.master.geometry(self._geom)
        self._geom = geom


def quit(*args):
    root.destroy()


def show_time():
    # Get the time remaining until the event
    remainder = endTime - datetime.datetime.now()
    # Show the time left
    txt.set(str(remainder)[2:-3])
    # Trigger the countdown after 1000ms
    root.after(1, show_time)


# Use tkinter lib for showing the clock
root = Tk()
# sw, sh = root.winfo_screenwidth(), root.winfo_screenheight()
# # print "screen1:",sw,sh
# w, h = 800, 600
# a, b = (sw-w)/2, (sh-h)/2
# # root.geometry('%sx%s+%s+%s'%(w, h, a, b))
# root.geometry("1920x1080+1921+0")
# root.attributes("-fullscreen", True)
root.configure(background='black')
root.bind("x", quit)
root.after(1, show_time)

# Set the end date and time for the countdown
endTime = datetime.datetime.now() + datetime.timedelta(0, 480)

fnt = font.Font(family='Helvetica', size=200, weight='bold')
txt = StringVar()
lbl = ttk.Label(root, textvariable=txt, font=fnt, foreground="red", background="black")
lbl.place(relx=0.5, rely=0.5, anchor=CENTER)

app = FullScreenApp(root)
root.mainloop()
