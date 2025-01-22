const consoleDiv = document.getElementById('console');
const inputField = document.getElementById('input');

function appendLine(text) {
    const line = document.createElement('div');
    line.className = 'line';
    line.textContent = text;
    consoleDiv.appendChild(line);

    setTimeout(() => {
    consoleDiv.scrollTop = consoleDiv.scrollHeight;
    }, 0);
}

inputField.addEventListener('keydown', function (e) {
    if (e.key === 'Enter' && inputField.value.trim() !== '') {
    const command = inputField.value.trim();
    inputField.value = '';

    appendLine(`C:\\> ${command}`);

    fetch(`https://${GetParentResourceName()}/executeCommand`, {
        method: 'POST',
        headers: {
        'Content-Type': 'application/json',
        },
        body: JSON.stringify({ command }),
    })
        .then((res) => res.json())
        .then((data) => {
        if (data && data.response) {
            appendLine(data.response);
        }
        })
        .catch((error) => {
            console.error('Error executing command:', error);
            // appendLine('Error executing command. Check the console for details.');
        });
    }
});

window.addEventListener('message', function (event) {
    if (event.data.action === 'open') {
        document.body.style.display = 'block';
        inputField.focus();
    } else if (event.data.action === 'close') {
        document.body.style.display = 'none';
    } else if (event.data.action === 'write') {
        appendLine(event.data.response);
    } else if (event.data.action === 'clear') {
        consoleDiv.innerHTML = '';
    }
});

document.body.style.display = 'none';