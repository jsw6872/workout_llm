from dotenv import load_dotenv
from openai import OpenAI
import os

load_dotenv()

WHISPER_API_KEY = os.getenv("GPT_API")

client = OpenAI(api_key = WHISPER_API_KEY)