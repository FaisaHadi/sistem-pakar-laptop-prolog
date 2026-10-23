const state = {
  history: [], answers: Object.create(null), current: 0,
  totalQuestions: 0, done: false, busy: false, error: '',
  started: false, knowledge: null, scope: null,
  context: { brand: 'tidak_diketahui', model: '' },
};
const answerChoices = [
  { value: 'ya', label: 'Ya', note: 'Sesuai dengan pengamatan', key: '1' },
  { value: 'tidak', label: 'Tidak', note: 'Sudah dinilai, tidak sesuai', key: '2' },
  { value: 'tidak_tahu', label: 'Tidak tahu', note: 'Belum diperiksa atau ragu', key: '3' },
];

const $ = (selector) => document.querySelector(selector);
const questionCard = $('#question-card');
const questionBody = $('#question-body');
const answerList = $('#answer-list');
const continueButton = $('#continue-button');
const backButton = $('#back-button');
const resultArea = $('#result-area');

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, (character) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
  })[character]);
}

function updateProgress() {
  const answered = Object.keys(state.answers).length;
  const total = state.totalQuestions;
  const coverage = total ? (answered / total) * 100 : 0;
  $('#answered-count').textContent = answered;
  $('#question-total').textContent = total || '…';
  $('#hero-count').textContent = total || '…';
  $('#progress-caption').textContent = state.done ? 'Penelusuran selesai' : 'Cakupan gejala';
  $('#progress-percent').textContent = state.done ? `${total - answered} dilewati` : `Maks. ${total || '…'}`;
  $('#mini-progress-fill').style.width = `${coverage}%`;
  $('#progress-track').setAttribute('aria-valuenow', String(answered));
  $('#progress-track').setAttribute('aria-valuemax', String(total || 15));
  $('#progress-fill').style.width = `${coverage}%`;
  $('#session-state').textContent = state.done ? 'SELESAI' : answered ? 'BERLANGSUNG' : 'SESI BARU';
}

function updateControls() {
  const question = state.history[state.current];
  const selected = question && state.answers[question.id];
  backButton.disabled = state.busy || state.current === 0;
  continueButton.disabled = !state.started || state.busy || (!selected && state.history.length > 0);
  $('#change-device').disabled = state.busy;
  continueButton.textContent = state.busy ? 'Menelusuri aturan…' : state.error ? 'Coba lagi' : 'Lanjut →';
  answerList.querySelectorAll('button').forEach((button) => { button.disabled = state.busy; });
  questionCard.setAttribute('aria-busy', String(state.busy));
  $('#request-error').hidden = !state.error;
  $('#request-error').textContent = state.error;
}

function renderQuestion(focus = false) {
  const question = state.history[state.current];
  if (!question || state.done) return;
  const selected = state.answers[question.id];
  $('#step-label').textContent = `PERTANYAAN ${String(state.current + 1).padStart(2, '0')} · ${question.id}`;
  questionBody.innerHTML = `<h3 id="question-prompt" tabindex="-1">${escapeHtml(question.prompt)}</h3><p>${escapeHtml(question.label)}</p>`;
  // Bantuan adalah bagian definisi gejala, sehingga selalu terlihat.
  $('#help-area').hidden = false;
  $('#question-help').textContent = question.help;
  const reason = question.reason;
  $('#question-reason').hidden = !reason;
  $('#question-reason').open = false;
  $('#reason-text').textContent = reason
    ? `Untuk memeriksa ${reason.diagnosis_id} — ${reason.name}, Prolog menelusuri ${reason.rules.join(' → ')}. Gejala ${question.id} diperlukan pada jalur ini.`
    : '';
  $('#reason-details').innerHTML = reason ? renderRuleDetails(reason.rule_details || []) : '';
  answerList.innerHTML = answerChoices.map((choice) => `
    <button class="answer-option${selected === choice.value ? ' selected' : ''}" type="button"
      data-answer="${choice.value}" aria-pressed="${selected === choice.value}">
      <span class="answer-number">${choice.key}</span><strong>${choice.label}</strong>
      <small>${choice.note}</small>
    </button>`).join('');
  answerList.querySelectorAll('.answer-option').forEach((button) => {
    button.addEventListener('click', () => {
      if (state.busy) return;
      // Koreksi menghapus jawaban sesudahnya karena jalur dapat berubah.
      if (state.answers[question.id] !== button.dataset.answer) {
        state.history.slice(state.current + 1).forEach((later) => { delete state.answers[later.id]; });
        state.history.length = state.current + 1;
      }
      state.answers[question.id] = button.dataset.answer;
      state.error = '';
      answerList.querySelectorAll('.answer-option').forEach((option) => {
        const active = option.dataset.answer === button.dataset.answer;
        option.classList.toggle('selected', active);
        option.setAttribute('aria-pressed', String(active));
      });
      updateControls();
      updateProgress();
    });
  });
  updateControls();
  updateProgress();
  if (focus) {
    $('#question-prompt').focus({ preventScroll: true });
    questionCard.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }
}

function answerText(answer) {
  if (answer === 'tidak_tahu') return 'Anda memilih tidak tahu';
  if (answer === 'belum_ditanya') return 'tidak ditanyakan pada jalur ini';
  return answer;
}

function renderList(items) {
  return `<ul>${items.map((item) => `<li>${escapeHtml(item.id)} — ${escapeHtml(item.label)}${item.answer ? ` <span>(${escapeHtml(answerText(item.answer))})</span>` : ''}</li>`).join('')}</ul>`;
}

function renderSources(sources) {
  return `<ul class="source-list">${sources.map((source) => `<li><a href="${escapeHtml(source.url)}" target="_blank" rel="noopener noreferrer">${escapeHtml(source.id)} — ${escapeHtml(source.title)}</a><br />Diakses ${escapeHtml(source.accessed)}. ${escapeHtml(source.limits)}</li>`).join('')}</ul>`;
}

function renderRuleDetails(rules) {
  return rules.map((rule) => {
    const matchingBrand = rule.sources.some((s) => s.brand === state.context.brand);
    const brandNote = state.context.brand !== 'tidak_diketahui' && !matchingBrand
      ? '<p class="scope-warning">Rujukan aturan ini belum spesifik untuk merek pilihan Anda. Cocokkan pengamatan dengan manual model; jika belum yakin, pilih tidak tahu.</p>' : '';
    return `<div class="rule-explanation"><strong>${escapeHtml(rule.id)} · ${escapeHtml(rule.status_label)}</strong>
      <p>JIKA ${rule.premises.map((p) => `${escapeHtml(p.id)} (${escapeHtml(p.label)})`).join(' DAN ')} MAKA ${escapeHtml(rule.conclusion.id)} (${escapeHtml(rule.conclusion.label)}).</p>
      <p>${escapeHtml(rule.limits)}</p>${brandNote}${renderSources(rule.sources)}</div>`;
  }).join('');
}

function diagnosisCard(diagnosis) {
  const status = diagnosis.status;
  const statusClass = status === 'didukung' ? 'supported' : status === 'belum_lengkap' ? 'incomplete' : 'unsupported';
  const order = { didukung: 0, belum_lengkap: 1, tidak_terpenuhi: 2 };
  const paths = [...diagnosis.paths].sort((a, b) => order[a.status] - order[b.status]).map((path, index) => `
    <div class="diagnosis-detail">
      <strong>Jalur ${index + 1}</strong> · ${escapeHtml(path.status_label)}<br />
      ${path.rules.map((rule) => `<span class="rule-chip">${escapeHtml(rule)}</span>`).join('')}
      ${path.positive.length ? `<div><strong>Premis yang dijawab ya</strong>${renderList(path.positive)}</div>` : ''}
      ${path.rejected.length ? `<div><strong>Premis yang dijawab tidak</strong>${renderList(path.rejected)}</div>` : ''}
      ${path.missing.length ? `<div><strong>Informasi yang belum tersedia</strong>${renderList(path.missing)}</div>` : ''}
      ${renderRuleDetails(path.rule_details || [])}
    </div>`).join('');
  const positive = new Map();
  diagnosis.paths.filter((path) => path.status === 'didukung')
    .forEach((path) => path.positive.forEach((symptom) => positive.set(symptom.id, symptom)));
  const advice = status === 'didukung' && diagnosis.advice
    ? `<div class="advice-box"><strong>Saran ${escapeHtml(diagnosis.advice.id)} · DRAF</strong><p>${escapeHtml(diagnosis.advice.text)}</p></div>` : '';
  return `<article class="diagnosis-card" data-diagnosis="${escapeHtml(diagnosis.id)}">
    <div class="diagnosis-title-row"><h3>${escapeHtml(diagnosis.id)} · ${escapeHtml(diagnosis.name)}</h3>
      <span class="status-badge ${statusClass}">${escapeHtml(diagnosis.status_label)}</span></div>
    ${positive.size ? `<div class="diagnosis-detail"><strong>Gejala pendukung</strong>${renderList([...positive.values()])}</div>` : ''}
    ${status === 'belum_lengkap' ? `<div class="diagnosis-detail"><strong>Informasi yang masih diperlukan</strong>${renderList(diagnosis.missing)}</div>` : ''}
    ${advice}
    <p class="diagnosis-detail"><strong>Batas kesimpulan:</strong> ${escapeHtml(diagnosis.limits)}</p>
    <details class="path-details"><summary>Lihat ${diagnosis.paths.length} jalur aturan, bukti, dan sumber</summary><p>${escapeHtml(diagnosis.alternatives_notice)}</p>${paths}</details>
  </article>`;
}

function renderResults(data) {
  state.done = true;
  questionCard.hidden = true;
  resultArea.hidden = false;
  const supported = data.diagnoses.filter((d) => d.status === 'didukung');
  const incomplete = data.diagnoses.filter((d) => d.status === 'belum_lengkap');
  const unsupported = data.diagnoses.filter((d) => d.status === 'tidak_terpenuhi');
  const heading = supported.length ? `${supported.length} dugaan awal sesuai dengan aturan.`
    : incomplete.length ? 'Informasi belum cukup untuk mendukung dugaan.' : 'Belum ada dugaan yang didukung aturan.';
  resultArea.innerHTML = `
    <div class="result-summary"><h2 id="result-heading" tabindex="-1">${escapeHtml(heading)}</h2><p>${escapeHtml(data.draft_notice)}</p>
      ${data.scope ? `<p class="scope-warning">${escapeHtml(data.scope.warning)}</p>` : ''}
      <p>Jawaban yang belum mendukung dugaan tidak berarti laptop Anda pasti sehat.</p></div>
    ${supported.map(diagnosisCard).join('')}
    ${incomplete.length ? `<h3 class="result-section-title">Informasi yang belum lengkap</h3>${incomplete.map(diagnosisCard).join('')}` : ''}
    ${unsupported.length ? `<details class="other-diagnoses"><summary>Lihat ${unsupported.length} dugaan yang belum didukung</summary>${unsupported.map(diagnosisCard).join('')}</details>` : ''}
    <div class="result-actions"><button class="restart-button" id="review-button" type="button">Tinjau jawaban</button>
      <button class="restart-button" id="restart-button" type="button">Mulai konsultasi baru ↻</button></div>`;
  $('#restart-button').addEventListener('click', restart);
  $('#review-button').addEventListener('click', () => {
    state.done = false;
    state.current = 0;
    resultArea.hidden = true;
    questionCard.hidden = false;
    renderQuestion(true);
  });
  updateProgress();
  $('#result-heading').focus({ preventScroll: true });
  resultArea.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

async function requestStep() {
  if (state.busy) return;
  state.busy = true;
  state.error = '';
  updateControls();
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 15000);
  try {
    const answers = Object.entries(state.answers).map(([id, answer]) => ({ id, answer }));
    const response = await fetch('/api/consult', {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ answers, context: state.context }), signal: controller.signal,
    });
    const data = await response.json().catch(() => null);
    if (!response.ok || !data) throw new Error(data?.error || 'Respons server belum dapat dibaca. Silakan coba lagi.');
    state.totalQuestions = data.total_questions;
    state.scope = data.scope;
    $('#device-label').textContent = `${data.scope.brand_label}${state.context.model ? ` — ${state.context.model}` : ' — model belum diisi'}. ${data.scope.warning}`;
    if (data.done) {
      renderResults(data.result);
    } else {
      state.history.push(data.question);
      state.current = state.history.length - 1;
      renderQuestion(true);
    }
  } catch (error) {
    state.error = error.name === 'AbortError'
      ? 'Server belum merespons. Jawaban Anda tetap tersimpan; tekan Coba lagi.'
      : error instanceof TypeError
        ? 'Koneksi ke server Prolog terputus. Pastikan server berjalan, lalu tekan Coba lagi.'
        : error.message;
  } finally {
    clearTimeout(timeout);
    state.busy = false;
    updateControls();
    updateProgress();
  }
}

function restart() {
  if (state.busy) return;
  state.answers = Object.create(null);
  state.history = [];
  state.current = 0;
  state.done = false;
  state.started = false;
  resultArea.hidden = true;
  resultArea.innerHTML = '';
  questionCard.hidden = true;
  $('#device-form').hidden = false;
  $('#device-summary').hidden = true;
  $('#help-area').hidden = true;
  $('#question-reason').hidden = true;
  questionBody.innerHTML = '<p>Menyiapkan pertanyaan…</p>';
  answerList.innerHTML = '';
  $('#step-label').textContent = 'MEMUAT KONSULTASI';
  state.error = '';
  updateControls();
  updateProgress();
  $('#device-heading').focus();
}

async function loadKnowledge() {
  $('#start-button').disabled = true;
  $('#start-button').textContent = 'Memuat cakupan...';
  $('#device-error').hidden = true;
  $('#retry-knowledge').hidden = true;
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 15000);
  try {
    const response = await fetch('/api/knowledge', { signal: controller.signal });
    if (!response.ok) throw new Error('Cakupan pengetahuan belum dapat dimuat.');
    const data = await response.json();
    state.knowledge = data;
    state.totalQuestions = data.total_questions;
    $('#scope-notice').textContent = data.scope.notice;
    $('#scope-sources').innerHTML = renderSources(data.sources);
    $('#device-brand').innerHTML = data.brands.map((b) => `<option value="${escapeHtml(b.id)}">${escapeHtml(b.label)}</option>`).join('');
    $('#device-brand').value = state.context.brand;
    $('#device-brand').disabled = false;
    $('#start-button').disabled = false;
    $('#start-button').textContent = 'Mulai konsultasi';
    updateProgress();
  } catch (error) {
    $('#device-error').textContent = 'Cakupan belum dapat dimuat. Pastikan server Prolog berjalan, lalu tekan Muat ulang cakupan.';
    $('#device-error').hidden = false;
    $('#retry-knowledge').hidden = false;
    $('#start-button').textContent = 'Mulai konsultasi';
  } finally { clearTimeout(timeout); }
}

$('#device-form').addEventListener('submit', (event) => {
  event.preventDefault();
  if (state.busy || !state.knowledge) return;
  state.context = { brand: $('#device-brand').value, model: $('#device-model').value.trim() };
  state.started = true;
  $('#device-form').hidden = true;
  $('#device-summary').hidden = false;
  questionCard.hidden = false;
  requestStep();
});
$('#retry-knowledge').addEventListener('click', loadKnowledge);
$('#change-device').addEventListener('click', restart);

backButton.addEventListener('click', () => {
  if (!state.busy && state.current > 0) {
    state.current -= 1;
    state.error = '';
    renderQuestion(true);
  }
});

continueButton.addEventListener('click', () => {
  if (state.busy) return;
  const question = state.history[state.current];
  if (question && !state.answers[question.id]) return;
  if (state.current < state.history.length - 1) {
    state.current += 1;
    renderQuestion(true);
  } else requestStep();
});

document.addEventListener('keydown', (event) => {
  if (event.altKey || event.ctrlKey || event.metaKey || !state.started || state.done || state.busy) return;
  if (['INPUT', 'TEXTAREA', 'SELECT'].includes(document.activeElement?.tagName)) return;
  const keyIndex = ['1', '2', '3'].indexOf(event.key);
  if (keyIndex >= 0) {
    event.preventDefault();
    answerList.querySelector(`[data-answer="${answerChoices[keyIndex].value}"]`)?.click();
  }
});

loadKnowledge();
