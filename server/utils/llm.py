import json
import openai
import time

from prompts import SYSTEM_PROMPT, USER_PROMPT_FORMAT
from . import client

def get_gpt_response(workout_contents):
    USER_PROMPT = USER_PROMPT_FORMAT.format(workout_contents=workout_contents)

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": USER_PROMPT},
        ],
        temperature = 0.2
    )
    result = response.choices[0].message.content

    return result

def get_organised_workout_contents(workout_contents):
    max_retries = 10

    while max_retries > 0:
        try:
            gpt_response = get_gpt_response(workout_contents)
            
            
            cleaned_gpt_response = gpt_response.strip('```json').strip()
            workout_content_dict = json.loads(cleaned_gpt_response)
            print(workout_content_dict)
            break
        except json.decoder.JSONDecodeError as e:
            max_retries -= 1
            print(e)
            print("JSONDecodeError 발생. 재시도합니다.")
            print(f"남은 재시도 횟수 : {max_retries}")
            time.sleep(2)
        except openai.error.RateLimitError as e:
            max_retries -= 1
            print(e)
            print("RateLimitError 발생. 재시도합니다.")
            print(f"남은 재시도 횟수 : {max_retries}")
            time.sleep(2)
        except Exception as e:
            max_retries -= 1
            print(e)
            print("기타 에러 발생. 재시도합니다.")
            print(f"남은 재시도 횟수 : {max_retries}")
            time.sleep(2)

    return workout_content_dict