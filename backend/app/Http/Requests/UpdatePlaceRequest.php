<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Http\Exceptions\HttpResponseException;

class UpdatePlaceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'category_id'         => ['sometimes', 'required', 'integer', 'exists:categories,id'],
            'name'                => ['sometimes', 'required', 'string', 'max:255'],
            'address'             => ['sometimes', 'required', 'string', 'max:500'],
            'latitude'            => ['sometimes', 'required', 'numeric', 'between:-90,90'],
            'longitude'           => ['sometimes', 'required', 'numeric', 'between:-180,180'],
            'description'         => ['sometimes', 'nullable', 'string'],
            'rating'              => ['sometimes', 'nullable', 'numeric', 'between:0,5'],
            'photo_url'           => ['sometimes', 'nullable', 'string', 'max:2048'],
            'opening_hours'       => ['sometimes', 'required', 'string', 'max:255'],

            'facility_ids'        => ['sometimes', 'array'],
            'facility_ids.*'      => ['integer', 'distinct', 'exists:facilities,id'],

            'fuels'               => ['sometimes', 'array'],
            'fuels.*.id'          => ['required_with:fuels', 'integer', 'distinct', 'exists:fuels,id'],
            'fuels.*.price'       => ['required_with:fuels', 'numeric', 'min:0'],
            'fuels.*.is_available'=> ['required_with:fuels', 'boolean'],
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        throw new HttpResponseException(
            response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors'  => $validator->errors(),
            ], 422)
        );
    }
}