"use strict";

const DOCUMENT_POSITION_SAME = 0;

// MARK: Current selection

function getRange() {
  const selection = document.getSelection();
  return selection?.rangeCount > 0 ? selection.getRangeAt(0) : null;
}
// MARK: Check element positions

function doesElementInteractWithRange(element, range) {
  const startPosition = element.compareDocumentPosition(range.startContainer);
  const endPosition = element.compareDocumentPosition(range.endContainer);

  const targetPositions = [DOCUMENT_POSITION_SAME,Node.DOCUMENT_POSITION_CONTAINS,Node.DOCUMENT_POSITION_CONTAINED_BY,];

  const doesElementIntersectStart = doesPositionMatchTargets(startPosition, targetPositions);
  const doesElementIntersectEnd = doesPositionMatchTargets(endPosition, targetPositions);
  const doesElementContainsRange = (
    doesPositionMatchTargets(startPosition, [Node.DOCUMENT_POSITION_PRECEDING]) &&
    doesPositionMatchTargets(endPosition, [Node.DOCUMENT_POSITION_FOLLOWING]) &&
    !doesPositionMatchTargets(endPosition, [Node.DOCUMENT_POSITION_CONTAINED_BY])
  );

  return (doesElementIntersectStart || doesElementIntersectEnd || doesElementContainsRange);
}

function doesPositionMatchTargets(position, targets) {
  return targets.some(
    (target) =>
      target === DOCUMENT_POSITION_SAME || (position & target) === target
  );
}

// MARK: Compare objects

function compareTextAttributes(lhs, rhs) {
  return (
    compareObjectProperties(lhs.format, rhs.format) &&
    compareObjectProperties(lhs.textInfo, rhs.textInfo)
  );
}

function compareObjectProperties(lhs, rhs) {
  if (Object.keys(lhs).length !== Object.keys(rhs).length) {
    return false;
  }
  return Object.entries(lhs).every(([key, value]) => rhs[key] === value);
}
