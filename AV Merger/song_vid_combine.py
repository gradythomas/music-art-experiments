import librosa
from moviepy.editor import *
from moviepy.video.VideoClip import *
import moviepy.video.fx.all as vfx
import numpy, scipy, matplotlib.pyplot as plt

from scipy import signal


def find_first_peak(audio, sr):
    """
    Uses librosa to find the first big peak in an audio signal.
    Takes a librosa audio object and returns the time delay of the first peak.
    """

    hop_length = 200 # samples per frame
    onset_env = librosa.onset.onset_strength(audio, sr=sr, hop_length=hop_length, n_fft=2048)
    frames = range(len(onset_env))
    t = librosa.frames_to_time(frames, sr=sr, hop_length=hop_length)
    peaks = signal.find_peaks(list(onset_env), height=2.0)[0]
    print(t[peaks[0]])
    return t[peaks[0]]

def process_audio(song_title, audio_start_offset, duration):
    """Processes the song to be put into the video"""

    song_audio, sr = librosa.load(song_title, offset=audio_start_offset, duration=duration)
    song_offset = find_first_peak(song_audio, sr)     # estimate first peak so we can start on the beat
    tempo = librosa.beat.tempo(song_audio, sr=sr)/2.0 # estimate song tempo and divide by 2 to get quarter notes
    # create an AudioFileClip object that MoviePy uses
    audio_clip = AudioFileClip(song_title).subclip(audio_start_offset, audio_start_offset+duration)

    return tempo, song_offset, audio_clip

def process_video(video_title, video_start_offset, duration):
    """Processes the video that will receive the song"""

    video_clip = VideoFileClip(video_title).subclip(video_start_offset,video_start_offset+duration) # create a VideoFileClip object for MoviePy
    video_music = video_clip.audio
    video_music.write_audiofile('video_music.wav') # strip out the audio from the video and write it to a file

    # process video music
    video_audio, sr2 = librosa.load('video_music.wav') # load that file into librosa so we can analyze the song from the video
    video_offset = find_first_peak(video_audio, sr2)     # estimate first peak so we can start on the beat
    tempo = librosa.beat.tempo(video_audio, sr=sr2)/2.0 # estimate song tempo and divide by 2 to get quarter notes

    return tempo, video_offset, video_clip

def combine_av(final_title, audio_clip, audio_tempo, audio_offset, video_clip, video_tempo, video_offset, duration):
    """Combines the song and video into a final product"""

    scale = audio_tempo[0]/video_tempo[0]
    print('Tempo of video: ', video_tempo, '\nTempo of song: ', audio_tempo, '\nScale by: ', scale)
    # scale and trim video
    video_clip = video_clip.fx(vfx.speedx, factor=scale).subclip(video_offset, duration+video_offset)
    # trim audio
    audio_clip = audio_clip.subclip(audio_offset, duration+audio_offset)
    # add them together
    video_clip = video_clip.set_audio(audio_clip)
    # write the final product to a file
    video_clip.subclip(0, duration).write_videofile(final_title, codec='libx264', 
                        audio_codec='aac', 
                        temp_audiofile='temp-audio.m4a', 
                        remove_temp=True)
    
    return

if __name__ == "__main__":
    t1, o1, audio_clip = process_audio('Songs/georgia_mail.flac', 2, 60)
    t2, o2, video_clip = process_video('Videos/rrr2.mp4', 0, 60)
    combine_av('Final Output/rrr_mail2.mp4', audio_clip, t1, o1, video_clip, t2, o2, 60)
