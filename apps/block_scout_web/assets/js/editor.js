import ClassicEditor from '@ckeditor/ckeditor5-build-classic'

ClassicEditor
    .create( document.querySelector( '.editor-ckeditor' ), {
        // toolbar: {
        //     items: [
        //         'link'
        //         // More toolbar items. 
        //         // ...
        //     ],
        // },
        link: {
            // Automatically add target="_blank" and rel="noopener noreferrer" to all external links.
            addTargetToExternalLinks: true,

            // Let the users control the "download" attribute of each link.
            decorators: [
                {
                    mode: 'manual',
                    label: 'Downloadable',
                    attributes: {
                        download: 'download'
                    }
                }
            ]
        }
    } )
    .catch( error => {
        console.error( error );
    } );

