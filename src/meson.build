sources = [
    'Service.vala'
]

libirobot = shared_library(
    meson.project_name(),
    sources,
    dependencies: [
        json_glib_1_dep,
        soup_dep,
    ],
    install: true
)

executable(
    'cli',
    'cli.vala',
    dependencies: [
        json_glib_1_dep,
        soup_dep,
    ],
    link_with: [
        libirobot
    ]
)
