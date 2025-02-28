window.addEventListener("message", function(event) {
    let data = event.data;

    if (data.type === "openMenu") {
        document.body.style.display = "flex";
        let vehicleList = document.getElementById("vehicleList");
        vehicleList.innerHTML = "";

        if (data.vehicles) {
            data.vehicles.forEach(vehicle => {
                let button = document.createElement("button");
                button.classList.add("vehicleButton");
                button.textContent = vehicle.name;
                button.onclick = function() {
                    fetch(`https://${GetParentResourceName()}/selectVehicle`, {
                        method: "POST",
                        headers: { "Content-Type": "application/json" },
                        body: JSON.stringify({ vehicleModel: vehicle.model })
                    });
                };
                vehicleList.appendChild(button);
            });
        }
    }

    if (data.type === "closeMenu") {
        document.body.style.display = "none";
    }
});

document.addEventListener("keydown", function(event) {
    if (event.key === "Escape") {
        fetch(`https://${GetParentResourceName()}/closeMenu`, { method: "POST" });
        document.body.style.display = "none";
    }
});
