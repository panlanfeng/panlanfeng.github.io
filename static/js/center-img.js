var imgs = document.getElementsByTagName('img'), i, img;
for (i = 0; i < imgs.length; i++) {
  img = imgs[i];
  if (img.parentElement.childElementCount === 1)
    img.parentElement.style.textAlign = 'center';
}
