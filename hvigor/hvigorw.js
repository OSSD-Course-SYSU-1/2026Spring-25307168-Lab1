const path = require('path');
const fs = require('fs');

const hvigorVersion = '3.0.2';
const hvigorCacheDir = path.join(__dirname, '.cache');
const hvigorJarPath = path.join(hvigorCacheDir, `hvigor-${hvigorVersion}.jar`);

function downloadHvigor() {
    // This is a placeholder - actual download should be done by DevEco Studio
    console.log('Please sync project in DevEco Studio to download Hvigor dependencies');
    process.exit(1);
}

function main() {
    const args = process.argv.slice(2);
    
    // Check if hvigor jar exists
    if (!fs.existsSync(hvigorJarPath)) {
        downloadHvigor();
    }
    
    // Execute hvigor
    const { execSync } = require('child_process');
    try {
        execSync(`node ${path.join(__dirname, 'hvigor-bin', 'hvigor.js')} ${args.join(' ')}`, {
            stdio: 'inherit',
            cwd: process.cwd()
        });
    } catch (error) {
        process.exit(error.status);
    }
}

main();
