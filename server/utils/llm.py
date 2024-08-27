import json
import openai
import time
from string import Template

from prompts.prompts_formatting import SYSTEM_PROMPT_FORMATTING, USER_PROMPT_FORMAT_FORMATTING
from prompts.prompts_recmd import SYSTEM_PROMPT_RECMD, USER_PROMPT_FORMAT_RECMD
from . import client

def get_gpt_response(system_prompt, user_prompt):

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": user_prompt},
        ],
        temperature = 0.2
    )
    result = response.choices[0].message.content

    return result

def get_organised_workout_contents(workout_contents):
    max_retries = 10

    system_prompt = SYSTEM_PROMPT_FORMATTING
    user_prompt = USER_PROMPT_FORMAT_FORMATTING.format(workout_contents=workout_contents)

    while max_retries > 0:
        try:
            gpt_response = get_gpt_response(system_prompt, user_prompt)
            
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

def get_recommended_workout_contents(start_date_to_recommended, dates_num_to_recommended, workout_contents_from_previous_5_days):

    max_retries = 10

    template = Template(SYSTEM_PROMPT_RECMD)
    system_prompt = template.substitute(
        dates_num_to_recommended=dates_num_to_recommended, start_date_to_recommended=start_date_to_recommended
    )

    user_prompt = USER_PROMPT_FORMAT_RECMD.format(workout_contents_from_previous_5_days=workout_contents_from_previous_5_days)

    while max_retries > 0:
        try:
            gpt_response = get_gpt_response(system_prompt, user_prompt)
            
            cleaned_gpt_response = gpt_response.strip('```python').strip()
            workout_content_recommended_list = json.loads(cleaned_gpt_response)
            break
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

    return workout_content_recommended_list