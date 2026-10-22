const state = { questions: [], answers: Object.create(null), current: 0, done: false };
const answerChoices = [
  { value: 'ya', label: 'Ya', note: 'Sesuai dengan pengamatan', key: '01' },
  { value: 'tidak', label: 'Tidak', note: 'Sudah dinilai, tidak sesuai', key: '02' },
  { value: 'tidak_tahu', label: 'Tidak tahu', note: 'Belum diperiksa atau ragu', key: '03' },
];

const $ = (selector) => document.querySelector(selector);
const questionCard = $('#question-card');
const questionBody = $('#question-body');
const answerList = $('#answer-list');
const questionHelp = $('#question-help');
const helpToggle = $('#help-toggle');
const continueButton = $('#continue-button');
const backButton = $('#back-button');
const resultArea = $('#result-area');
let toastTimer;

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, (character) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
  })[character]);
}

function showToast(message) {
  const toast = $('#toast');
  toast.textContent = message;
  toast.classList.add('visible');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => toast.classList.remove('visible'), 3000);
}

function updateProgress() {
  const total = state.questions.length;
  const answered = Object.keys(state.answers).length;
  const percent = total ? Math.round((answered / total) * 100) : 0;
  $('#answered-count').textContent = answered;
  $('#question-total').textContent = total;
  $('#progress-percent').textContent = `${percent}%`;
  $('#mini-progress-fill').style.width = `${percent}%`;
  $('#progress-track').setAttribute('aria-valuenow', String(state.current + 1));
  $('#progress-track').setAttribute('aria-valuemax', String(total));
  $('#progress-fill').style.width = `${total ? ((state.current + 1) / total) * 100 : 0}%`;
}

function renderQuestion() {
  if (!state.questions.length || state.done) return;
  const question = state.questions[state.current];
  const selected = state.answers[question.id];
  $('#step-label').textContent = `PERTANYAAN ${String(state.current + 1).padStart(2, '0')} / ${String(state.questions.length).padStart(2, '0')}`;
  questionBody.innerHTML = `<h3>${escapeHtml(question.prompt)}</h3><p>${escapeHtml(question.label)}</p>`;
  questionHelp.textContent = question.help;
  questionHelp.hidden = true;
  helpToggle.setAttribute('aria-expanded', 'false');
  helpToggle.querySelector('span').textContent = '＋';
  answerList.innerHTML = answerChoices.map((choice) => `
    <button class="answer-option${selected === choice.value ? ' selected' : ''}" type="button"
      data-answer="${choice.value}" aria-pressed="${selected === choice.value}">
      <span class="answer-number">${choice.key}</span>
      <strong>${choice.label}</strong>
      <small>${choice.note}</small>
    </button>`).join('');
  answerList.querySelectorAll('.answer-option').forEach((button) => {
    button.addEventListener('click', () => {
      state.answers[question.id] = button.dataset.answer;
      renderQuestion();
      answerList.querySelector(`[data-answer="${button.dataset.answer}"]`).focus();
    });
  });
  backButton.disabled = state.current === 0;
  continueButton.disabled = !selected;
  continueButton.innerHTML = state.current === state.questions.length - 1
    ? 'Lihat ringkasan <span aria-hidden="true">↗</span>'
    : 'Lanjut <span aria-hidden="true">→</span>';
  updateProgress();
}

function renderList(items, emptyMessage) {
  if (!items?.length) return `<span>${escapeHtml(emptyMessage)}</span>`;
  return `<ul>${items.map((item) => `<li>${escapeHtml(item.id)} — ${escapeHtml(item.label)}${item.answer ? ` <span>(${escapeHtml(answerText(item.answer))})</span>` : ''}</li>`).join('')}</ul>`;
}

function answerText(answer) {
  if (answer === 'tidak_tahu') return 'belum diketahui';
  if (answer === 'belum_ditanya') return 'belum ditanyakan';
  return answer;
}

function statusClass(status) {
  return status === 'didukung' ? 'supported' : status === 'belum_lengkap' ? 'incomplete' : 'unsupported';
}

function diagnosisCard(diagnosis) {
  const paths = diagnosis.paths.map((path, index) => `
    <div class="diagnosis-detail">
      <strong>Jalur ${index + 1}</strong> ${escapeHtml(path.status_label)}<br />
      ${path.rules.map((rule) => `<span class="rule-chip">${escapeHtml(rule)}</span>`).join('')}
      ${path.positive.length ? `<div><strong>Gejala yang sesuai</strong>${renderList(path.positive, '')}</div>` : ''}
      ${path.rejected.length ? `<div><strong>Jawaban yang tidak sesuai</strong>${renderList(path.rejected, '')}</div>` : ''}
      ${path.missing.length ? `<div><strong>Informasi yang belum tersedia</strong>${renderList(path.missing, '')}</div>` : ''}
    </div>`).join('');
  const advice = diagnosis.status === 'didukung' && diagnosis.advice
    ? `<div class="advice-box"><strong>Saran ${escapeHtml(diagnosis.advice.id)} · DRAF</strong><br />${escapeHtml(diagnosis.advice.text)}</div>`
    : '';
  return `<article class="diagnosis-card">
    <div class="diagnosis-title-row"><h3>${escapeHtml(diagnosis.id)} · ${escapeHtml(diagnosis.name)}</h3>
      <span class="status-badge ${statusClass(diagnosis.status)}">${escapeHtml(diagnosis.status_label)}</span></div>
    ${paths || '<p class="diagnosis-detail">Belum ada jalur aturan yang sesuai dengan jawaban Anda.</p>'}
    ${diagnosis.status === 'belum_lengkap' ? `<div class="diagnosis-detail"><strong>Yang masih diperlukan</strong>${renderList(diagnosis.missing, 'Belum ada informasi tambahan.')}</div>` : ''}
    ${advice}
  </article>`;
}

function renderResults(data) {
  state.done = true;
  questionCard.hidden = true;
  resultArea.hidden = false;
  const heading = data.supported_count
    ? `${data.supported_count} dugaan awal memiliki gejala yang mendukung.`
    : 'Ringkasan konsultasi Anda sudah siap.';
  resultArea.innerHTML = `
    <div class="result-summary"><p class="eyebrow">02 / HASIL PENELUSURAN</p><h2>${escapeHtml(heading)}</h2><p>${escapeHtml(data.draft_notice)}</p></div>
    ${data.diagnoses.map(diagnosisCard).join('')}
    <button class="restart-button" id="restart-button" type="button">Mulai konsultasi baru <span aria-hidden="true">↻</span></button>`;
  $('#restart-button').addEventListener('click', restart);
  updateProgress();
  resultArea.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

async function diagnose() {
  continueButton.disabled = true;
  continueButton.textContent = 'Menelusuri aturan...';
  try {
    const answers = state.questions.map((question) => ({ id: question.id, answer: state.answers[question.id] }));
    const response = await fetch('/api/diagnose', {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ answers }),
    });
    const data = await response.json();
    if (!response.ok) throw new Error(data.error || 'Hasil belum dapat dibuat.');
    renderResults(data);
  } catch (error) {
    showToast(error.message || 'Koneksi ke mesin Prolog terputus.');
    continueButton.disabled = false;
    continueButton.innerHTML = 'Coba lagi <span aria-hidden="true">↗</span>';
  }
}

function restart() {
  state.answers = Object.create(null);
  state.current = 0;
  state.done = false;
  resultArea.hidden = true;
  resultArea.innerHTML = '';
  questionCard.hidden = false;
  renderQuestion();
  questionCard.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

helpToggle.addEventListener('click', () => {
  const isOpen = !questionHelp.hidden;
  questionHelp.hidden = isOpen;
  helpToggle.setAttribute('aria-expanded', String(!isOpen));
  helpToggle.querySelector('span').textContent = isOpen ? '＋' : '−';
});

backButton.addEventListener('click', () => {
  if (state.current > 0) { state.current -= 1; renderQuestion(); }
});

continueButton.addEventListener('click', () => {
  if (!state.answers[state.questions[state.current]?.id]) return;
  if (state.current < state.questions.length - 1) {
    state.current += 1;
    renderQuestion();
    questionCard.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
  } else diagnose();
});

document.addEventListener('keydown', (event) => {
  if (event.altKey || event.ctrlKey || event.metaKey || state.done) return;
  const activeTag = document.activeElement?.tagName;
  if (activeTag === 'INPUT' || activeTag === 'TEXTAREA') return;
  const keyIndex = Number(event.key) - 1;
  if (keyIndex >= 0 && keyIndex < answerChoices.length) {
    answerList.querySelector(`[data-answer="${answerChoices[keyIndex].value}"]`)?.click();
  }
});

async function initialize() {
  try {
    const response = await fetch('/api/questions');
    if (!response.ok) throw new Error('Daftar pertanyaan tidak dapat dimuat.');
    const data = await response.json();
    state.questions = data.questions;
    $('#hero-count').textContent = state.questions.length;
    renderQuestion();
  } catch (error) {
    questionBody.innerHTML = `<h3>Konsultasi belum bisa dimuat.</h3><p>${escapeHtml(error.message)}</p>`;
    answerList.innerHTML = '<button class="restart-button" type="button" onclick="location.reload()">Coba lagi</button>';
    showToast('Pastikan server SWI-Prolog sedang berjalan.');
  }
}

initialize();
