async function trigger() {
  console.log("Triggering 5 archives in parallel...");

  const promises = [];
  for (let i = 0; i < 5; i++) {
    promises.push(
      fetch("http://localhost:3000/api/cron/generate-daily", { method: "POST" })
        .then((res) => res.json())
        .then((data) =>
          console.log(`Archive ${i + 1} generated:`, data?.archive?.[0]?.title),
        )
        .catch((e) => console.error(`Error on archive ${i + 1}:`, e.message)),
    );
  }

  await Promise.allSettled(promises);
  console.log("Done.");
}
trigger();
