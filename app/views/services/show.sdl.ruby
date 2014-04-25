if params[:sdl_part]
  @service.sdl_parts[params[:sdl_part]]
else
  @service.to_service_sdl
end