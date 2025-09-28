// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
  integrations: [
    starlight({
      title: 'dot.umeru.ma',
      social: [{
        icon: 'github',
        label: 'GitHub',
        href: 'https://github.com/umeruma/dotfiles' 
      }],
      sidebar: [
        { label: 'home', slug: 'index' },
        {
          label: 'etc',
          items: [
            { label: 'Setup Hardware', slug: 'etc/setup-hard' },
            { label: 'Lean zsh', slug: 'etc/lean-zsh' },
          ],
        },
      ],
    }),
  ],
});
