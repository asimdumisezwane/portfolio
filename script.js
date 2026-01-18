const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add("show");
    }
  });
});

document.querySelectorAll(".hidden").forEach((el) => observer.observe(el));

const text = "Welcome to my portfolio!";
let index = 0;
let started = false;

function typeWelcome() {
  if (index < text.length) {
    document.getElementById("type").innerHTML += text.charAt(index);
    index++;
    setTimeout(typeWelcome, 120);   
  }
}

window.onload = typeWelcome;

const welcomeObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting && !started) {
      started = true;
      typeWelcome();
    }
  });
});

welcomeObserver.observe(document.querySelector(".welcome"));