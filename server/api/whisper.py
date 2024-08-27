from fastapi import APIRouter, File, UploadFile, HTTPException
import os
import shutil
from datetime import datetime

from utils import log, whisper, llm

router = APIRouter(
    prefix = "/whisper",
    tags = ["whisper"],
    responses = {404: {"description": "Not found"}}
)

# 이건 내 개인 API를 사용할 때만 사용함. (제공받은 API 사용 시에는 필요없음)
@router.get("/devonly/log-whisper")
def log_whisper():
    total_string, remaining_string = log.load_total_audio_length()
    return {
        "total_audio_length": total_string,
        "remaining_audio_length": remaining_string
    }

@router.post("/audio-to-workout-content")
def audio_to_workout_content(file: UploadFile = File(...)):
    
    # 파일 이름을 현재 시간을 이용해 변경
    only_file_name = '.'.join(file.filename.split('.')[:-1])
    now = (datetime.now()).strftime('%Y%m%d_%H%M%S')
    full_file_name = f"{now}_{only_file_name}.{file.filename.split('.')[-1]}"

    file_location = f"audio_files/{full_file_name}"
    
    # 디렉토리가 없으면 생성
    os.makedirs(os.path.dirname(file_location), exist_ok=True)
    
    # 파일을 서버에 저장
    with open(file_location, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # Whisper API를 사용해 음성 파일을 텍스트로 변환
    script = whisper.get_script_by_whisper(file_location)

    ##################################################################
    ## 로깅은 내 개인 API를 사용할 때만 사용함. (제공받은 API 사용 시에는 필요없음) ##
    ##################################################################

    # log.log_audio_length(file_location)

    # total_string, remaining_string = log.load_total_audio_length()
    audio_length = log.calculate_audio_length(file_location)

    # 터미널에 출력
    label_width = max(len("file_location"), len("audio_length"), len("total_length"), len("remaining_length"))

    print("[Whisper API Results]", flush = True)
    print(f"{'file_location'.ljust(label_width)} : {file_location}", flush = True)
    print(f"{'audio_length'.ljust(label_width)} : {audio_length}", flush = True)
    # print(f"{'total_length'.ljust(label_width)} : {total_string}", flush = True)
    # print(f"{'remaining_length'.ljust(label_width)} : {remaining_string}", flush = True)

    ##################################################################
    ##################################################################

    # LLM을 사용해 텍스트를 처리 (json 형태로 반환)

    workout_content_dict = llm.get_organised_workout_contents(script)

    return workout_content_dict