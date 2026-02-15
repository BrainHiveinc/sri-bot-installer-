// Agent Sri - WhatsApp Bot
// Copyright (c) 2026 BrainHive Inc. Free to use
const { Client, LocalAuth } = require('whatsapp-web.js');
const { spawn } = require('child_process');
const qrcode = require('qrcode-terminal');
const path = require('path');

const AGENT_CLI = path.join(__dirname, 'agent_cli_protected.py');

const client = new Client({
    authStrategy: new LocalAuth()
});

console.log('');
console.log('╔══════════════════════════════════════════════════════════════╗');
console.log('║    🤖 Agent Sri - WhatsApp Bot (FREE)                      ║');
console.log('╚══════════════════════════════════════════════════════════════╝');
console.log('');
console.log('✅ Memory enabled (50 messages)');
console.log('✅ File reading (PDF, text, images)');
console.log('✅ URL fetching and learning');
console.log('✅ Free to use');
console.log('');

client.on('qr', (qr) => {
    console.log('📱 Scan QR code with WhatsApp:');
    console.log('');
    qrcode.generate(qr, { small: true });
});

client.on('ready', () => {
    console.log('✅ WhatsApp bot ready!');
    console.log('Send a message to your WhatsApp');
});

async function getAgentResponse(userId, message) {
    return new Promise((resolve, reject) => {
        console.log(\`📩 Message from \${userId}: \${message}\`);

        const python = spawn('python3', [AGENT_CLI, userId, message]);

        let output = '';
        let errorOutput = '';

        python.stdout.on('data', (data) => {
            output += data.toString();
        });

        python.stderr.on('data', (data) => {
            errorOutput += data.toString();
        });

        python.on('close', (code) => {
            if (code !== 0) {
                console.error('❌ Agent error:', errorOutput);
                reject(new Error(errorOutput || 'Agent failed'));
            } else {
                console.log('✅ Agent response received');
                resolve(output.trim() || 'No response from agent');
            }
        });
    });
}

client.on('message', async (msg) => {
    if (msg.from === 'status@broadcast') return;

    const userId = msg.from;
    const messageText = msg.body;

    try {
        const response = await getAgentResponse(userId, messageText);
        await msg.reply(response);
    } catch (error) {
        console.error('Error:', error.message);
        await msg.reply('Sorry, something went wrong. Please try again.');
    }
});

client.initialize();
