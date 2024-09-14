function main() {
  (function () {
    let syllablesEl = document.querySelector('.word-syllables-entry');
    let syllables;
    if (syllablesEl) {
      syllables = syllablesEl.innerText;
    } else {
      syllables = document.querySelector('.hword').innerText;
    }
    let prons = document.querySelector('.prons-entries-list-inline').querySelectorAll('a.prons-entry-list-item');
    let result = `${syllables};${prons[prons.length-1].innerText}`.trim();
    console.log(result);
  })();
}

main();
