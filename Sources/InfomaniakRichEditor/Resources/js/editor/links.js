// MARK: Detect links

function hasLink() {
    return getAllAnchorsOfSelection().length > 0;
  }
  
  function getAllAnchorsOfSelection() {
    const range = getRange();
    return range
      ? [...swiftRichEditor.querySelectorAll("a[href]")].filter((element) =>
          doesElementInteractWithRange(element, range)
        )
      : [];
  }
  function getFirstAnchorOfSelection() {
    const anchors = getAllAnchorsOfSelection();
    return anchors.length > 0 ? anchors[0] : null;
  }
  
  // MARK: Create and edit links
  
  function createLink(text, url) {
    const range = getRange();
    if (range === null) {
      return;
    }
  
    const trimmedText = text.trim();
    const formattedText = trimmedText === "" ? null : trimmedText;
  
    if (range.collapsed) {
      createLinkForCaret(formattedText, url, range);
    } else {
      createLinkForRange(formattedText, url);
    }
  }
  
  function createLinkForCaret(text, url, range) {
    let anchor = getFirstAnchorOfSelection();
    if (anchor !== null) {
      anchor.href = url;
      updateAnchorText(anchor, text);
    } else {
      anchor = document.createElement("a");
      anchor.textContent = text || url;
      anchor.href = url;
      range.insertNode(anchor);
    }
  
    setCaretAtEndOfAnchor(anchor);
  }
  
  function createLinkForRange(text, url) {
    document.execCommand("createLink", false, url);
  
    if (text !== null) {
      const anchor = getFirstAnchorOfSelection();
      updateAnchorText(anchor, text);
    }
  }
  
  // MARK: Remove link
  
  function unlink() {
    let anchorNodes = getAllAnchorsOfSelection();
    anchorNodes.forEach(unlinkAnchorNode);
  }
  
  function unlinkAnchorNode(anchor) {
    const selection = document.getSelection();
    if (selection.rangeCount <= 0) {
      return;
    }
  
    const range = selection.getRangeAt(0);
    const rangeBackup = range.cloneRange();
  
    range.selectNodeContents(anchor);
    document.execCommand("unlink");
  
    selection.removeAllRanges();
    selection.addRange(rangeBackup);
  }
  
  // MARK: Utils
  
  function updateAnchorText(anchor, text) {
    if (text !== null && anchor.textContent !== text) {
      anchor.textContent = text;
    }
  }
  
  function setCaretAtEndOfAnchor(anchor) {
    const range = new Range();
    range.setStart(anchor, 1);
    range.setEnd(anchor, 1);
    range.collapsed = true;
  
    const selection = document.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
  }
  