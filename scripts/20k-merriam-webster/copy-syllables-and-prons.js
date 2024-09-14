(function () {
  let syllables = document.querySelector('.word-syllables-entry').innerText;
  let prons = document.querySelector('.prons-entries-list-inline').querySelectorAll('.prons-entry-list-item');
  copy(`${syllables};${prons[prons.length-1].innerText}`.trim());
})();
