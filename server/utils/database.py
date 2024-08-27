import json

def get_all_workouts_data():
    # all_workouts.json 파일을 읽어서 workouts를 반환
    with open('database/all_workouts.json', 'r') as f:
        workouts = json.load(f)
    return workouts

def dump_workouts(workouts):
    # workouts를 all_workouts.json 파일로 저장
    with open('database/all_workouts.json', 'w') as f:
        json.dump(workouts, f)

def create_workout(workout_content_dict):
    workouts = get_all_workouts_data()
    workouts.append(workout_content_dict)
    dump_workouts(workouts)

def get_workout_contents(date_list):
    workouts = get_all_workouts_data()
    workout_contents = []
    for workout in workouts:
        if workout['date'] in date_list:
            workout_contents.append(workout)
    return workout_contents