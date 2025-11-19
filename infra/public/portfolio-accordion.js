// Script pour rendre le portfolio avec effet accordéon
document.addEventListener('DOMContentLoaded', function() {
    // Sélectionner toutes les cartes de projet
    const projectCards = document.querySelectorAll('.project-card');
    
    projectCards.forEach(card => {
        // Trouver le titre - gérer les deux structures possibles
        let titleElement = card.querySelector('.project-title');
        
        // Si structure spéciale du premier projet
        if (!titleElement) {
            const headerClickable = card.querySelector('.project-header-clickable');
            if (headerClickable) {
                const titleText = headerClickable.querySelector('.project-title-text');
                if (titleText) {
                    // Créer un nouveau titre unifié
                    titleElement = document.createElement('div');
                    titleElement.className = 'project-title';
                    
                    // Extraire l'icône initiale
                    const iconElement = titleText.querySelector('i.fab, i.fas');
                    let iconHTML = '';
                    if (iconElement) {
                        iconHTML = iconElement.outerHTML + ' ';
                    }
                    
                    // Extraire le lien GitHub
                    const linkElement = titleText.querySelector('a');
                    let githubHref = null;
                    if (linkElement) {
                        githubHref = linkElement.href;
                    }
                    
                    // Extraire le badge de statut
                    const statusElement = headerClickable.querySelector('.project-status');
                    
                    // Copier le texte sans l'icône ni le lien
                    let text = '';
                    titleText.childNodes.forEach(node => {
                        if (node.nodeType === Node.TEXT_NODE) {
                            text += node.textContent;
                        } else if (node.nodeType === Node.ELEMENT_NODE && node.tagName !== 'A' && node.tagName !== 'I') {
                            text += node.textContent;
                        }
                    });
                    text = text.replace(/🔗/g, '').trim();
                    
                    // Construire le nouveau titre avec l'icône
                    titleElement.innerHTML = iconHTML + text;
                    
                    // Ajouter le badge de statut si existe
                    if (statusElement) {
                        titleElement.appendChild(document.createTextNode(' '));
                        titleElement.appendChild(statusElement.cloneNode(true));
                    }
                    
                    // Ajouter le lien GitHub si existe
                    if (githubHref) {
                        const github = document.createElement('a');
                        github.href = githubHref;
                        github.target = '_blank';
                        github.className = 'project-github-link';
                        github.innerHTML = '<i class="fab fa-github"></i>';
                        github.onclick = (e) => e.stopPropagation();
                        titleElement.appendChild(github);
                    }
                    
                    // Remplacer l'ancien header par le nouveau titre
                    headerClickable.replaceWith(titleElement);
                    
                    // Renommer project-content-collapsible en project-steps
                    const oldContent = card.querySelector('.project-content-collapsible');
                    if (oldContent) {
                        const newSteps = document.createElement('div');
                        newSteps.className = 'project-steps';
                        newSteps.innerHTML = oldContent.innerHTML;
                        oldContent.replaceWith(newSteps);
                    }
                }
            }
        }
        
        // Maintenant traiter le titre uniformisé
        titleElement = card.querySelector('.project-title');
        let stepsElement = card.querySelector('.project-steps');
        
        if (!titleElement) return;
        
        // Extraire le badge de statut et le retirer du titre
        const statusBadge = titleElement.querySelector('.project-status');
        if (statusBadge) {
            statusBadge.remove();
        }
        
        // Récupérer TOUT le texte du titre AVANT de modifier quoi que ce soit
        const fullTitleText = titleElement.textContent;
        
        // Détecter les badges AVANT de faire les modifications
        const has42 = fullTitleText.includes('(Projet 42)') || fullTitleText.includes('Projet 42');
        const hasPerso = fullTitleText.includes('(Projet perso)');
        const hasBootcamp = fullTitleText.includes('(Bootcamp Data)') || fullTitleText.includes('Bootcamp Data');
        
        // Extraire tous les liens GitHub
        const links = titleElement.querySelectorAll('a');
        let githubLink = null;
        let linkText = '';
        links.forEach(link => {
            if (link.href && link.href.includes('github.com')) {
                githubLink = link.href;
                // Récupérer le texte du lien (sans le 🔗)
                linkText = link.textContent.replace(/🔗/g, '').trim();
                link.remove(); // Retirer le lien du titre
            }
        });
        
        // Nettoyer le texte du titre (enlever emoji, texte "Terminé", etc.)
        // Si on a un linkText, l'utiliser, sinon utiliser le textContent
        let titleText = linkText || titleElement.textContent
            .replace(/🔗/g, '')
            .replace(/Terminé/g, '')
            .replace(/En cours/g, '')
            .replace(/Planifié/g, '')
            .trim();
        
        // Nettoyer les mentions de projets du titre
        titleText = titleText.replace(/\(Projet 42\)/g, '').replace(/Projet 42/g, '').trim();
        titleText = titleText.replace(/\(Projet perso\)/g, '').trim();
        titleText = titleText.replace(/\(Bootcamp Data\)/g, '').replace(/Bootcamp Data/g, '').trim();
        
        // Sauvegarder le contenu HTML complet du titre (avec icônes)
        const originalHTML = titleElement.innerHTML;
        
        // Appliquer les styles au titre
        titleElement.style.cursor = 'pointer';
        titleElement.style.userSelect = 'none';
        titleElement.style.display = 'flex';
        titleElement.style.alignItems = 'center';
        titleElement.style.gap = '0.5rem';
        titleElement.style.flexWrap = 'wrap';
        
        // Créer le span pour le texte avec l'icône d'origine
        const titleSpan = document.createElement('span');
        titleSpan.style.flexGrow = '1';
        titleSpan.style.flexBasis = '100%'; // Force le retour à la ligne après le titre
        
        // Récupérer l'icône d'origine si elle existe
        const originalIcon = titleElement.querySelector('i.fab, i.fas:not(.project-toggle-icon)');
        let iconHTML = '';
        if (originalIcon) {
            iconHTML = originalIcon.outerHTML + ' ';
        }
        
        titleSpan.innerHTML = iconHTML + titleText;
        
        // Vider le titre et ajouter le nouveau span
        titleElement.innerHTML = '';
        titleElement.appendChild(titleSpan);
        
        // Ajouter le badge École 42 si nécessaire
        if (has42) {
            const badge42 = document.createElement('span');
            badge42.className = 'project-badge-42';
            badge42.textContent = '42';
            badge42.style.fontSize = '0.75rem';
            badge42.style.padding = '0.2rem 0.6rem';
            badge42.style.backgroundColor = 'rgba(74, 106, 154, 0.15)';
            badge42.style.borderRadius = '10px';
            badge42.style.fontWeight = '600';
            badge42.style.color = 'var(--color-accent)';
            titleElement.appendChild(badge42);
        }
        
        // Ajouter le badge Perso si nécessaire
        if (hasPerso) {
            const badgePerso = document.createElement('span');
            badgePerso.className = 'project-badge-perso';
            badgePerso.textContent = 'Perso';
            badgePerso.style.fontSize = '0.75rem';
            badgePerso.style.padding = '0.2rem 0.6rem';
            badgePerso.style.backgroundColor = 'rgba(74, 106, 154, 0.15)';
            badgePerso.style.borderRadius = '10px';
            badgePerso.style.fontWeight = '600';
            badgePerso.style.color = 'var(--color-accent)';
            titleElement.appendChild(badgePerso);
        }
        
        // Ajouter le badge Bootcamp si nécessaire
        if (hasBootcamp) {
            const badgeBootcamp = document.createElement('span');
            badgeBootcamp.className = 'project-badge-bootcamp';
            badgeBootcamp.textContent = 'Bootcamp Data';
            badgeBootcamp.style.fontSize = '0.75rem';
            badgeBootcamp.style.padding = '0.2rem 0.6rem';
            badgeBootcamp.style.backgroundColor = 'rgba(74, 106, 154, 0.15)';
            badgeBootcamp.style.borderRadius = '10px';
            badgeBootcamp.style.fontWeight = '600';
            badgeBootcamp.style.color = 'var(--color-accent)';
            titleElement.appendChild(badgeBootcamp);
        }
        
        // Ajouter l'icône GitHub si lien existe
        if (githubLink) {
            const githubIcon = document.createElement('a');
            githubIcon.href = githubLink;
            githubIcon.target = '_blank';
            githubIcon.className = 'project-github-link';
            githubIcon.innerHTML = '<i class="fab fa-github"></i>';
            githubIcon.onclick = function(e) {
                e.stopPropagation();
            };
            titleElement.appendChild(githubIcon);
        }
        
        // Ajouter l'icône chevron
        const chevron = document.createElement('i');
        chevron.className = 'fas fa-chevron-down project-toggle-icon';
        titleElement.appendChild(chevron);
        
        // Si pas de stepsElement, créer un conteneur pour tout le contenu après le titre
        if (!stepsElement) {
            stepsElement = document.createElement('div');
            stepsElement.className = 'project-steps';
            
            // Déplacer tout le contenu restant dans stepsElement (y compris objectifs)
            let nextElement = titleElement.nextElementSibling;
            while (nextElement) {
                const currentElement = nextElement;
                nextElement = nextElement.nextElementSibling;
                stepsElement.appendChild(currentElement);
            }
        } else {
            // Si stepsElement existe, vérifier s'il y a du contenu après (comme les objectifs)
            let nextNode = stepsElement.nextSibling; // Utiliser nextSibling au lieu de nextElementSibling
            while (nextNode) {
                const currentNode = nextNode;
                nextNode = nextNode.nextSibling;
                // Ajouter tous les nœuds (éléments ET textes) dans stepsElement
                stepsElement.appendChild(currentNode);
            }
        }
        
        // Ajouter le badge de statut au début du contenu
        if (statusBadge) {
            const statusP = document.createElement('p');
            statusP.appendChild(statusBadge);
            statusP.style.marginBottom = '1rem';
            stepsElement.insertBefore(statusP, stepsElement.firstChild);
        }
        
        // Nettoyer tous les emojis 🎯 dans le contenu
        const walker = document.createTreeWalker(
            stepsElement,
            NodeFilter.SHOW_TEXT,
            null,
            false
        );
        
        const textNodes = [];
        while (walker.nextNode()) {
            textNodes.push(walker.currentNode);
        }
        
        textNodes.forEach(node => {
            if (node.textContent.includes('🎯')) {
                node.textContent = node.textContent.replace(/🎯\s*/g, '');
            }
        });
        
        // Créer le wrapper pour l'accordéon
        const contentWrapper = document.createElement('div');
        contentWrapper.className = 'project-content-collapsible';
        contentWrapper.style.maxHeight = '0';
        contentWrapper.style.overflow = 'hidden';
        contentWrapper.style.transition = 'max-height 0.4s ease';
        
        // Déplacer stepsElement dans le wrapper
        contentWrapper.appendChild(stepsElement);
        
        // Insérer le wrapper après le titre
        titleElement.after(contentWrapper);
        
        // Gérer le clic sur le titre
        titleElement.addEventListener('click', function(e) {
            // Ne pas déclencher si on clique sur un lien
            if (e.target.tagName === 'A' || e.target.closest('a')) {
                return;
            }
            
            const isOpen = contentWrapper.style.maxHeight && contentWrapper.style.maxHeight !== '0px';
            
            if (isOpen) {
                // Fermer
                contentWrapper.style.maxHeight = '0';
                chevron.style.transform = 'rotate(0deg)';
                card.classList.remove('project-expanded');
            } else {
                // Ouvrir
                contentWrapper.style.maxHeight = contentWrapper.scrollHeight + 'px';
                chevron.style.transform = 'rotate(180deg)';
                card.classList.add('project-expanded');
            }
        });
    });
});
