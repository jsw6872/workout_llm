from fastapi import APIRouter

from utils import database

router = APIRouter(
    prefix = "/database",
    tags = ["database"],
    responses = {404: {"description": "Not found"}}
)
@router.get("/all")
def get_all_workouts():
    data = database.get_all_workouts_data()
    return {"data": data}

@router.post("/")
def create_workout(workout_content_dict: dict):
    database.create_workout(workout_content_dict)
    return {"message": "Workout created successfully"}