from . import client

def get_script_by_whisper(file_location):
    # Whisper API를 사용해 음성 파일을 텍스트로 변환
    with open(file_location, "rb") as audio_file:
        transcript = client.audio.transcriptions.create(
            model="whisper-1",
            file=audio_file
        )

    # Whisper API 결과로부터 텍스트 추출
    text = transcript.text

    return text

