import "./style.css";
// Import MoonBit module via mbt: prefix
import "mbt:internal/app";

const centerSvgScroll = () => {
  const wrap = document.querySelector<HTMLDivElement>(".svg-wrap");
  if (!wrap) {
    return;
  }
  const maxScroll = wrap.scrollWidth - wrap.clientWidth;
  wrap.scrollLeft = maxScroll > 0 ? Math.floor(maxScroll / 2) : 0;
};

const bindSvgScrollCentering = () => {
  const wrap = document.querySelector<HTMLDivElement>(".svg-wrap");
  const stage = wrap?.querySelector<HTMLDivElement>(".svg-stage");
  if (!wrap || !stage) {
    return;
  }
  const observer = new MutationObserver(() => centerSvgScroll());
  observer.observe(stage, { childList: true, subtree: true });
  window.addEventListener("resize", centerSvgScroll);
  centerSvgScroll();
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", bindSvgScrollCentering);
} else {
  bindSvgScrollCentering();
}
