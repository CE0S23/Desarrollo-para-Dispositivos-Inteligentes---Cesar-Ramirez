const CARD_IDS = ['card-queretaro', 'card-cdmx', 'card-guadalajara', 'card-monterrey'];

const NAV_MAP = {
  'card-queretaro':    { down: 'card-guadalajara', right: 'card-cdmx' },
  'card-cdmx':         { down: 'card-monterrey',   left: 'card-queretaro' },
  'card-guadalajara':  { up: 'card-queretaro',      right: 'card-monterrey' },
  'card-monterrey':    { up: 'card-cdmx',           left: 'card-guadalajara' },
};

let currentFocusIndex = 0;

function getCardElement(id) {
  return document.getElementById(id);
}

function focusCard(index) {
  CARD_IDS.forEach(id => {
    const el = getCardElement(id);
    if (el) el.classList.remove('focused');
  });

  currentFocusIndex = Math.max(0, Math.min(index, CARD_IDS.length - 1));
  const target = getCardElement(CARD_IDS[currentFocusIndex]);
  if (target) {
    target.classList.add('focused');
    target.focus({ preventScroll: true });
  }
}

function moveFocus(direction) {
  const currentId = CARD_IDS[currentFocusIndex];
  const map = NAV_MAP[currentId];
  if (!map) return;

  const targetId = map[direction];
  const targetIndex = CARD_IDS.indexOf(targetId);
  if (targetIndex !== -1) {
    focusCard(targetIndex);
  }
}

function handleKeyDown(e) {
  const key = e.key;
  const focusedEl = document.activeElement;
  const isOnCard = focusedEl && focusedEl.classList.contains('city-card');

  if (!isOnCard) {
    if (['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'Enter', ' '].includes(key)) {
      focusCard(0);
      e.preventDefault();
    }
    return;
  }

  switch (key) {
    case 'ArrowUp':
      moveFocus('up');
      e.preventDefault();
      break;
    case 'ArrowDown':
      moveFocus('down');
      e.preventDefault();
      break;
    case 'ArrowLeft':
      moveFocus('left');
      e.preventDefault();
      break;
    case 'ArrowRight':
      moveFocus('right');
      e.preventDefault();
      break;
    case 'Enter':
    case ' ':
      e.preventDefault();
      focusedEl.dispatchEvent(new CustomEvent('card-select', {
        bubbles: true,
        detail: { city: focusedEl.dataset.city, cardId: focusedEl.id },
      }));
      break;
  }
}

function initNavigation() {
  document.addEventListener('keydown', handleKeyDown);
  focusCard(0);
}
