from pydub import AudioSegment
from datetime import timedelta, datetime

def calculate_audio_length(audio_file):
    # Get the audio file duration in seconds
    audio = AudioSegment.from_file(audio_file)
    duration = len(audio) / 1000  # Convert milliseconds to seconds
    return duration

def log_audio_length(audio_name):
    audio_length = calculate_audio_length(audio_name)
    # 'log.csv'파일을 열어서 audio_name과 audio_length를 기록한다.
    # 현재 시간도 기록한다.
    now = (datetime.now()).strftime('%Y-%m-%d %H:%M:%S')
    with open('log.csv', 'a') as f:
        f.write(f'{audio_name},{audio_length},{now}\n')

def load_total_audio_length():
    # 'log.csv'파일을 열어서 총 오디오 길이를 계산한다.
    total = 0
    with open('./log.csv', 'r') as f:
        for line in f:
            _, audio_length, _ = line.strip().split(',')
            total += float(audio_length)
    # total을 몇시간 몇분 몇초로 출력한다.
    hours = int(total // 3600)
    minutes = int((total % 3600) // 60)
    seconds = int(total % 60)

    total_string = f'{hours}시간 {minutes}분 {seconds}초'

    # 남은 시간 출력
    total_timedelta = timedelta(seconds=total)
    limit = timedelta(hours=13, minutes=53)
    remaining = limit - total_timedelta

    hours = remaining.seconds // 3600
    minutes = (remaining.seconds % 3600) // 60
    seconds = remaining.seconds % 60

    remaining_string = f'{hours}시간 {minutes}분 {seconds}초'

    return total_string, remaining_string

def log_whisper(file_location):
    log_audio_length(file_location)
    total_string, remaining_string = load_total_audio_length()
    return total_string, remaining_string