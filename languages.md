# Prompts: languages.ipynb

My exact prompts from the chat session that produced [languages.ipynb](./languages.ipynb), in order.

## Prompt 1

> i added languages.csv, looking to setup a jupyter notebook, remember i use vs code, so no juypyter installs needed, exploring with one hot encoding, so maybe sections on load data, one hot encode degree of endagerment, then linear regression on those with number of speakers, not even sure that makes sense, but naively think one hot makes lin reg possible, or teach me in the notebook, i will activate venv and run all cells manuall btw

## Prompt 2

> wait, what tool failing, how can i help

## Prompt 3

> some errors running a few of those cells, in saved notebook

## Prompt 4

> my exact prompts in languages.md, along with a brief brief summary of your work

---

## Summary of the work

- Built `languages.ipynb` with sections: Load Data → Explore Data → One-Hot Encode
  `Degree of endangerment` → Linear Regression → Bonus: Log-Transformed Target →
  Takeaways. Markdown cells teach *why* each step matters, including the honest point
  that one-hot encoding makes a categorical column usable by linear regression but
  doesn't manufacture a strong relationship that isn't in the data.
- Added `scikit-learn`, `matplotlib`, and `ipykernel` to `pyproject.toml` dependencies
  (only `pandas` was listed before).
- VS Code's notebook-editing tools (`createJupyterNotebook`/`editNotebook`) failed with
  an opaque error in this session, so the notebook was generated via a throwaway Python
  script that wrote the `.ipynb` JSON directly, then the script was deleted.
- When you reported cell errors, diagnosed two real data-quality issues in
  `languages.csv` and fixed the notebook accordingly:
  - 183 rows missing `Number of speakers` → caused `ValueError: Input y contains NaN.`
    during `model.fit`. Fix: drop rows missing the target early, with a markdown
    explanation of why dropping (not imputing) is correct for a missing *target*.
  - 257 rows with `Number of speakers == 0` → caused `log10(0) = -inf`, which broke the
    bonus log-transform regression. Fix: filter to speakers > 0 before log-transforming,
    with a markdown note that this is mostly (not only) the `"Extinct"` category.
- Verified the full notebook logic end-to-end by running it as a script against the
  project's `.venv` Python before handing it back, confirming it executes cleanly and
  reporting the resulting $R^2$ values (raw scale: weak/negative; log scale:
  ~0.34–0.43), matching the notebook's own teaching narrative.
