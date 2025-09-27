import fs from 'fs';
import path from 'path';

const src = path.resolve(__dirname, '..', 'src', 'content', 'docs', 'index.md');

if (fs.existsSync(src)) {
    const real = fs.realpathSync.native(src);
    if (real !== src) {
        const content = fs.readFileSync(real, 'utf8');
        fs.writeFileSync(src, content, 'utf8');
        console.log('Resolved symlink:', src, '->', real);
    } else {
        console.log('No symlink to resolve for', src);
    }
} else {
    console.log('Source file does not exist:', src);
}