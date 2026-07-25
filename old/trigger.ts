async function trigger() {
  console.log("Triggering 5 archives...");
  for (let i = 0; i < 5; i++) {
    console.log(`Triggering archive ${i + 1}...`);
    try {
      const res = await fetch("http://localhost:3000/api/cron/generate-daily", {
        method: "POST",
      });
      const data = await res.json();
      console.log(`Archive ${i + 1} generated:`, data);
    } catch (e) {
      console.error(`Error on archive ${i + 1}:`, e);
    }
  }
}

trigger();
