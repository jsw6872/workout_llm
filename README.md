# Workout_LLM

### Server Side
- setup conda environment
```bash
conda create -n workout_llm python=3.10
conda activate workout_llm
pip install -r requirements.txt
```
- run server
```bash
cd server
uvicorn main:app --port 8080 --host 0.0.0.0 --reload
```