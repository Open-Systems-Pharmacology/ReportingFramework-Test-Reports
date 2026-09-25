#' Custom Plot Function: Annotated Time Profiles
#'
#' This custom plot function extends plotTimeProfiles with additional annotations
#' and customizations such as confidence intervals, reference lines, or styling.
#'
#' @param projectConfiguration An object containing the project configuration settings.
#' @param onePlotConfig A data.table containing the configuration for the specific plot.
#' @param ... Additional arguments passed from runPlot, including scenarioList, pkParameterDT, etc.
#'
#' @return A list of customized plot objects.
#'
plotCustomAnnotatedTimeProfiles <- function(
    projectConfiguration,
    onePlotConfig,
    ...
) {
    plotName <- dplyr::coalesce(
        onePlotConfig$PlotName[[1]],
        onePlotConfig$plotName[[1]]
    )

    # Initialize list of plots
    plotList <- list()

    # Call the default timeprofile plotting function
    plotList <- ospsuite.reportingframework::plotTimeProfiles(
        projectConfiguration = projectConfiguration,
        onePlotConfig = onePlotConfig,
        ...
    )

    # Customize each plot in the list with additional annotations
    for (plotKey in names(plotList)) {
        plotObject <- plotList[[plotKey]]

        # Add custom styling and annotations
        if (ggplot2::is_ggplot(plotObject)) {
            # Add reference line at y=0 for comparison
            plotList[[plotKey]] <- plotObject +
                ggplot2::geom_hline(
                    yintercept = 0,
                    linetype = "dashed",
                    color = "gray50",
                    alpha = 0.5,
                    linewidth = 0.3
                ) +
                # Add custom theme enhancements
                ggplot2::theme(
                    panel.grid.major = ggplot2::element_line(
                        color = "gray90",
                        linewidth = 0.2
                    ),
                    panel.grid.minor = ggplot2::element_line(
                        color = "gray95",
                        linewidth = 0.1
                    ),
                    legend.position = "top",
                    legend.title = ggplot2::element_blank()
                )

            # Update export attributes with custom caption
            plotList[[
                plotKey
            ]] <- ospsuite.reportingframework::setExportAttributes(
                object = plotList[[plotKey]],
                caption = paste0(
                    "Customized Time Profile Plot - ",
                    plotName,
                    " with reference lines and enhanced styling"
                ),
                footNoteLines = "Generated using custom annotated time profile function"
            )
        }
    }

    return(plotList)
}

#' Validation Function for Custom Annotated Time Profiles Configuration
#'
#' Validates the configuration table for the custom plot function.
#'
#' @param configTable A data.table containing the configuration for the plot.
#' @param ... Additional arguments for customization.
#'
#' @return invisible NULL if valid, otherwise throws an error.
#'
validateCustomAnnotatedTimeProfilesConfig <- function(configTable, ...) {
    # Check for required columns
    requiredColOptions <- list(
        c("Level", "Header", "PlotName"),
        c("level", "header", "plotName")
    )
    matchingCols <- requiredColOptions[[which.max(vapply(
        requiredColOptions,
        function(cols) sum(cols %in% colnames(configTable)),
        integer(1)
    ))]]
    missingCols <- setdiff(matchingCols, colnames(configTable))

    if (length(missingCols) > 0) {
        stop(
            "Configuration table is missing required columns: ",
            paste(missingCols, collapse = ", ")
        )
    }

    invisible(NULL)
}
