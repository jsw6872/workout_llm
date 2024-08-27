from fastapi import APIRouter
from typing import *
import shutil
from datetime import datetime, timedelta

from utils import llm, database

router = APIRouter(
    prefix = "/llm",
    tags = ["llm"],
    responses = {404: {"description": "Not found"}}
)

@router.post("/recommended-workouts")
def get_recommended_workouts(start_date_to_recommended: str, dates_num_to_recommended: int):

    # workout_dates_to_recommended의 0번째 날짜 기준 이전 5일간의 날짜 리스트 생성
    today = start_date_to_recommended
    date_format = "%Y-%m-%d"
    today_datetime = datetime.strptime(today, date_format)
    date_list = []
    for i in range(1, 6):
        date = today_datetime - timedelta(days=i)
        date_list.append(date.strftime(date_format))
    
    # 이전 5일간의 운동 기록을 가져옴
    workout_contents_from_previous_5_days = database.get_workout_contents(date_list)

    # workout_dates_to_recommended로 LLM에게 추천받기
    workout_content_recommended_list = llm.get_recommended_workout_contents(start_date_to_recommended, dates_num_to_recommended, workout_contents_from_previous_5_days)
    # 받은 결과를 반환
    return {"workout_content_recommended_list": workout_content_recommended_list}